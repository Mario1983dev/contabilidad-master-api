require('dotenv').config();

const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const officeUsersRoutes = require('./routes/office-users.routes');
const pool = require('./db');
const officesRoutesFactory = require('./routes/offices.routes');
const companiesRoutes = require('./routes/companies.routes');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use('/office-users', officeUsersRoutes(pool));
app.use('/offices', officesRoutesFactory(pool));
app.use('/companies', companiesRoutes(pool));

/* ======================================================
   ROOT
====================================================== */
app.get('/', (req, res) => {
  res.json({ message: 'Contabilidad Master API funcionando' });
});

/* ======================================================
   LOGIN GENERAL
   POST /api/login
   Acepta username, email o usernameOrEmail
   Orden:
   1) master_users
   2) office_admins
   3) office_users
====================================================== */
app.post('/api/login', async (req, res) => {
  try {
    const { email, username, usernameOrEmail, password } = req.body || {};
    const loginValue = String(usernameOrEmail || username || email || '').trim();

    if (!loginValue || !password) {
      return res.status(400).json({
        message: 'Usuario/email y password son obligatorios'
      });
    }

    /* ======================================================
       1) BUSCAR EN MASTER_USERS
       Importante: soporta tablas master_users con o sin username
    ====================================================== */
    let masterRows = [];

    try {
      const [rows] = await pool.query(
        `SELECT id, username, email, password_hash, is_active
         FROM master_users
         WHERE username = ? OR email = ?
         LIMIT 1`,
        [loginValue, loginValue]
      );
      masterRows = rows;
    } catch (error) {
      const [rows] = await pool.query(
        `SELECT id, email, password_hash, is_active
         FROM master_users
         WHERE email = ?
         LIMIT 1`,
        [loginValue]
      );
      masterRows = rows;
    }

    if (masterRows.length > 0) {
      const masterUser = masterRows[0];

      if (!Number(masterUser.is_active)) {
        return res.status(403).json({
          message: 'Usuario inactivo'
        });
      }

      const okMaster = bcrypt.compareSync(
        password,
        String(masterUser.password_hash || '').trim()
      );

      if (!okMaster) {
        return res.status(401).json({
          message: 'Credenciales inválidas'
        });
      }

      const token = jwt.sign(
        {
          id: masterUser.id,
          username: masterUser.username || null,
          email: masterUser.email,
          role: 'MASTER',
          scope: 'master'
        },
        process.env.JWT_SECRET || 'solusoft_secret',
        {
          expiresIn: process.env.JWT_EXPIRES_IN || '8h'
        }
      );

      return res.json({
        token,
        user: {
          id: masterUser.id,
          username: masterUser.username || null,
          email: masterUser.email,
          role: 'MASTER',
          scope: 'master'
        }
      });
    }

    /* ======================================================
       2) BUSCAR EN OFFICE_ADMINS
    ====================================================== */
    const [officeAdminRows] = await pool.query(
      `SELECT id, office_id, username, email, password_hash, is_active
       FROM office_admins
       WHERE username = ? OR email = ?
       LIMIT 1`,
      [loginValue, loginValue]
    );

    if (officeAdminRows.length > 0) {
      const officeAdmin = officeAdminRows[0];

      if (!Number(officeAdmin.is_active)) {
        return res.status(403).json({
          message: 'Usuario inactivo'
        });
      }

      const okOfficeAdmin = bcrypt.compareSync(
        password,
        String(officeAdmin.password_hash || '').trim()
      );

      if (!okOfficeAdmin) {
        return res.status(401).json({
          message: 'Credenciales inválidas'
        });
      }

      const token = jwt.sign(
        {
          id: officeAdmin.id,
          office_id: officeAdmin.office_id,
          username: officeAdmin.username || null,
          email: officeAdmin.email,
          role: 'OFFICE_ADMIN',
          scope: 'office_admin'
        },
        process.env.JWT_SECRET || 'solusoft_secret',
        {
          expiresIn: process.env.JWT_EXPIRES_IN || '8h'
        }
      );

      return res.json({
        token,
        user: {
          id: officeAdmin.id,
          office_id: officeAdmin.office_id,
          username: officeAdmin.username || null,
          email: officeAdmin.email,
          role: 'OFFICE_ADMIN',
          scope: 'office_admin'
        }
      });
    }

    /* ======================================================
       3) BUSCAR EN OFFICE_USERS
    ====================================================== */
    const [officeUserRows] = await pool.query(
      `SELECT id, office_id, username, name, email, password_hash, is_active
       FROM office_users
       WHERE username = ? OR email = ?
       LIMIT 1`,
      [loginValue, loginValue]
    );

    if (officeUserRows.length > 0) {
      const officeUser = officeUserRows[0];

      if (!Number(officeUser.is_active)) {
        return res.status(403).json({
          message: 'Usuario inactivo'
        });
      }

      const okOfficeUser = bcrypt.compareSync(
        password,
        String(officeUser.password_hash || '').trim()
      );

      if (!okOfficeUser) {
        return res.status(401).json({
          message: 'Credenciales inválidas'
        });
      }

      const token = jwt.sign(
        {
          id: officeUser.id,
          office_id: officeUser.office_id,
          username: officeUser.username,
          email: officeUser.email,
          role: 'OFFICE_USER',
          scope: 'office_user'
        },
        process.env.JWT_SECRET || 'solusoft_secret',
        {
          expiresIn: process.env.JWT_EXPIRES_IN || '8h'
        }
      );

      return res.json({
        token,
        user: {
          id: officeUser.id,
          office_id: officeUser.office_id,
          username: officeUser.username,
          name: officeUser.name,
          email: officeUser.email,
          role: 'OFFICE_USER',
          scope: 'office_user'
        }
      });
    }

    return res.status(401).json({
      message: 'Credenciales inválidas'
    });

  } catch (err) {
    console.error('LOGIN ERROR:', err);
    return res.status(500).json({
      message: 'Error interno del servidor'
    });
  }
});

/* ======================================================
   LOGIN MASTER ANTIGUO (OPCIONAL)
====================================================== */
app.post('/api/master/login', async (req, res) => {
  try {
    const { email, username, usernameOrEmail, password } = req.body || {};
    const loginValue = String(usernameOrEmail || username || email || '').trim();

    if (!loginValue || !password) {
      return res.status(400).json({
        message: 'Email/usuario y password son obligatorios'
      });
    }

    let rows = [];

    try {
      const [result] = await pool.query(
        `SELECT id, username, email, password_hash, is_active
         FROM master_users
         WHERE username = ? OR email = ?
         LIMIT 1`,
        [loginValue, loginValue]
      );
      rows = result;
    } catch (error) {
      const [result] = await pool.query(
        `SELECT id, email, password_hash, is_active
         FROM master_users
         WHERE email = ?
         LIMIT 1`,
        [loginValue]
      );
      rows = result;
    }

    if (!rows || rows.length === 0) {
      return res.status(401).json({
        message: 'Credenciales inválidas'
      });
    }

    const user = rows[0];

    if (!Number(user.is_active)) {
      return res.status(403).json({
        message: 'Usuario inactivo'
      });
    }

    const ok = bcrypt.compareSync(
      password,
      String(user.password_hash || '').trim()
    );

    if (!ok) {
      return res.status(401).json({
        message: 'Credenciales inválidas'
      });
    }

    const token = jwt.sign(
      {
        id: user.id,
        username: user.username || null,
        email: user.email,
        role: 'MASTER',
        scope: 'master'
      },
      process.env.JWT_SECRET || 'solusoft_secret',
      {
        expiresIn: process.env.JWT_EXPIRES_IN || '8h'
      }
    );

    return res.json({
      token,
      user: {
        id: user.id,
        username: user.username || null,
        email: user.email,
        role: 'MASTER',
        scope: 'master'
      }
    });
  } catch (err) {
    console.error('LOGIN MASTER ERROR:', err);
    return res.status(500).json({
      message: 'Error interno del servidor'
    });
  }
});

/* ======================================================
   MIDDLEWARE JWT
====================================================== */
function verifyToken(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({
      message: 'Token requerido'
    });
  }

  const token = authHeader.startsWith('Bearer ')
    ? authHeader.slice(7).trim()
    : '';

  if (!token) {
    return res.status(401).json({
      message: 'Token requerido'
    });
  }

  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'solusoft_secret'
    );

    req.user = decoded;
    return next();
  } catch (err) {
    return res.status(401).json({
      message: 'Token inválido'
    });
  }
}

function requireMaster(req, res, next) {
  if (!req.user || req.user.role !== 'MASTER') {
    return res.status(403).json({
      message: 'No autorizado'
    });
  }

  return next();
}

/* ======================================================
   ROUTES: OFFICES (PROTEGIDO)
====================================================== */
app.use(
  '/api/master/offices',
  verifyToken,
  requireMaster,
  officesRoutesFactory(pool)
);

/* ======================================================
   404
====================================================== */
app.use((req, res) => {
  res.status(404).json({
    message: 'Ruta no encontrada'
  });
});

/* ======================================================
   SERVER
====================================================== */
const PORT = Number(process.env.PORT) || 3000;

app.listen(PORT, () => {
  console.log(`Master API corriendo en puerto ${PORT}`);
});