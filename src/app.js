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
   LOGIN GENERAL (YA ESTÁ PERFECTO)
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

    /* ===== MASTER ===== */
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
    } catch {
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
      const u = masterRows[0];

      if (!Number(u.is_active)) {
        return res.status(403).json({ message: 'Usuario inactivo' });
      }

      const ok = bcrypt.compareSync(password, String(u.password_hash).trim());

      if (!ok) {
        return res.status(401).json({ message: 'Credenciales inválidas' });
      }

      const token = jwt.sign(
        {
          id: u.id,
          username: u.username || null,
          email: u.email,
          role: 'MASTER',
          scope: 'master'
        },
        process.env.JWT_SECRET,
        { expiresIn: '8h' }
      );

      return res.json({
        token,
        user: {
          id: u.id,
          username: u.username || null,
          email: u.email,
          role: 'MASTER',
          scope: 'master'
        }
      });
    }

    /* ===== OFFICE ADMIN ===== */
    const [admins] = await pool.query(
      `SELECT id, office_id, username, email, password_hash, is_active
       FROM office_admins
       WHERE username = ? OR email = ?
       LIMIT 1`,
      [loginValue, loginValue]
    );

    if (admins.length > 0) {
      const u = admins[0];

      if (!Number(u.is_active)) {
        return res.status(403).json({ message: 'Usuario inactivo' });
      }

      const ok = bcrypt.compareSync(password, String(u.password_hash).trim());

      if (!ok) {
        return res.status(401).json({ message: 'Credenciales inválidas' });
      }

      const token = jwt.sign(
        {
          id: u.id,
          office_id: u.office_id,
          username: u.username,
          email: u.email,
          role: 'OFFICE_ADMIN',
          scope: 'office_admin'
        },
        process.env.JWT_SECRET,
        { expiresIn: '8h' }
      );

      return res.json({
        token,
        user: {
          id: u.id,
          office_id: u.office_id,
          username: u.username,
          email: u.email,
          role: 'OFFICE_ADMIN',
          scope: 'office_admin'
        }
      });
    }

    /* ===== OFFICE USER ===== */
    const [users] = await pool.query(
      `SELECT id, office_id, username, name, email, password_hash
       FROM office_users
       WHERE username = ? OR email = ?
       LIMIT 1`,
      [loginValue, loginValue]
    );

    if (users.length > 0) {
      const u = users[0];

      const ok = bcrypt.compareSync(password, String(u.password_hash).trim());

      if (!ok) {
        return res.status(401).json({ message: 'Credenciales inválidas' });
      }

      const token = jwt.sign(
        {
          id: u.id,
          office_id: u.office_id,
          username: u.username,
          email: u.email,
          role: 'OFFICE_USER',
          scope: 'office_user'
        },
        process.env.JWT_SECRET,
        { expiresIn: '8h' }
      );

      return res.json({
        token,
        user: {
          id: u.id,
          office_id: u.office_id,
          username: u.username,
          name: u.name,
          email: u.email,
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
   ROUTES PROTEGIDAS (USANDO NUEVO MIDDLEWARE)
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