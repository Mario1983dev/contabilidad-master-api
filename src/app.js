require('dotenv').config();

const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const officeUsersRoutes = require('./routes/office-users.routes');
const officesRoutesFactory = require('./routes/offices.routes');
const companiesRoutes = require('./routes/companies.routes');
const accountsRoutes = require('./routes/accounts.routes');
const journalEntriesRoutes = require('./routes/journal-entries.routes');

const { authenticateToken, allowRoles } = require('./middlewares/auth.middleware');

const pool = require('./db');

const app = express();

/* ======================================================
   MIDDLEWARE BASE
====================================================== */
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

/* ======================================================
   ROOT
====================================================== */
app.get('/', (req, res) => {
  res.json({ message: 'Contabilidad Master API funcionando' });
});

/* ======================================================
   HELPERS LOGIN
====================================================== */
async function findMasterUserByEmail(email) {
  try {
    const [rows] = await pool.query(
      `SELECT id, username, email, password_hash, is_active
       FROM master_users
       WHERE email = ?
       LIMIT 1`,
      [email]
    );

    return rows.length > 0 ? rows[0] : null;
  } catch {
    const [rows] = await pool.query(
      `SELECT id, email, password_hash, is_active
       FROM master_users
       WHERE email = ?
       LIMIT 1`,
      [email]
    );

    return rows.length > 0 ? rows[0] : null;
  }
}

async function findOfficeAdminByUsername(username) {
  const [rows] = await pool.query(
    `SELECT id, office_id, username, email, password_hash, is_active
     FROM office_admins
     WHERE username = ?
     LIMIT 1`,
    [username]
  );

  return rows.length > 0 ? rows[0] : null;
}

async function findOfficeUserByUsername(username) {
  const [rows] = await pool.query(
    `SELECT id, office_id, username, name, email, password_hash
     FROM office_users
     WHERE username = ?
     LIMIT 1`,
    [username]
  );

  return rows.length > 0 ? rows[0] : null;
}

/* ======================================================
   LOGIN GENERAL
   - MASTER: email
   - OFFICE_ADMIN: username
   - OFFICE_USER: username
   - Compatible con frontend que envía usernameOrEmail
====================================================== */
app.post('/api/login', async (req, res) => {
  try {
    const { email, username, usernameOrEmail, password } = req.body || {};

    const rawLogin = String(
      usernameOrEmail || email || username || ''
    ).trim();

    if (!rawLogin || !password) {
      return res.status(400).json({
        message: 'Usuario/email y password son obligatorios'
      });
    }

    const isEmailLogin = rawLogin.includes('@');

    /* ===== MASTER → SOLO EMAIL ===== */
    if (isEmailLogin) {
      const masterUser = await findMasterUserByEmail(rawLogin);

      if (!masterUser) {
        return res.status(401).json({ message: 'Credenciales inválidas' });
      }

      if (!Number(masterUser.is_active)) {
        return res.status(403).json({ message: 'Usuario inactivo' });
      }

      const ok = bcrypt.compareSync(
        password,
        String(masterUser.password_hash).trim()
      );

      if (!ok) {
        return res.status(401).json({ message: 'Credenciales inválidas' });
      }

      const token = jwt.sign(
        {
          id: masterUser.id,
          username: masterUser.username || null,
          email: masterUser.email,
          role: 'MASTER',
          scope: 'master'
        },
        process.env.JWT_SECRET,
        { expiresIn: '8h' }
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

    /* ===== OFFICE ADMIN → SOLO USERNAME ===== */
    const officeAdmin = await findOfficeAdminByUsername(rawLogin);

    if (officeAdmin) {
      if (!Number(officeAdmin.is_active)) {
        return res.status(403).json({ message: 'Usuario inactivo' });
      }

      const ok = bcrypt.compareSync(
        password,
        String(officeAdmin.password_hash).trim()
      );

      if (!ok) {
        return res.status(401).json({ message: 'Credenciales inválidas' });
      }

      const token = jwt.sign(
        {
          id: officeAdmin.id,
          office_id: officeAdmin.office_id,
          username: officeAdmin.username,
          email: officeAdmin.email,
          role: 'OFFICE_ADMIN',
          scope: 'office_admin'
        },
        process.env.JWT_SECRET,
        { expiresIn: '8h' }
      );

      return res.json({
        token,
        user: {
          id: officeAdmin.id,
          office_id: officeAdmin.office_id,
          username: officeAdmin.username,
          email: officeAdmin.email,
          role: 'OFFICE_ADMIN',
          scope: 'office_admin'
        }
      });
    }

    /* ===== OFFICE USER → SOLO USERNAME ===== */
    const officeUser = await findOfficeUserByUsername(rawLogin);

    if (officeUser) {
      const ok = bcrypt.compareSync(
        password,
        String(officeUser.password_hash).trim()
      );

      if (!ok) {
        return res.status(401).json({ message: 'Credenciales inválidas' });
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
        process.env.JWT_SECRET,
        { expiresIn: '8h' }
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

    return res.status(401).json({ message: 'Credenciales inválidas' });

  } catch (err) {
    console.error('LOGIN ERROR:', err);
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
});

/* ======================================================
   ROUTES PROTEGIDAS
====================================================== */
app.use('/companies', companiesRoutes(pool));
app.use('/office-users', officeUsersRoutes(pool));
app.use('/accounts', accountsRoutes(pool));
app.use('/journal-entries', journalEntriesRoutes(pool));

/* ======================================================
   MASTER ONLY
====================================================== */
app.use(
  '/api/master/offices',
  authenticateToken,
  allowRoles('MASTER'),
  officesRoutesFactory(pool)
);

/* ======================================================
   404
====================================================== */
app.use((req, res) => {
  res.status(404).json({ message: 'Ruta no encontrada' });
});

/* ======================================================
   SERVER
====================================================== */
const PORT = Number(process.env.PORT) || 3000;

app.listen(PORT, () => {
  console.log(`Master API corriendo en puerto ${PORT}`);
});