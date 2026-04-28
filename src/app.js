require('dotenv').config();

const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const path = require('path');

const officeUsersRoutes = require('./routes/office-users.routes');
const officesRoutesFactory = require('./routes/offices.routes');
const companiesRoutes = require('./routes/companies.routes');
const accountsRoutes = require('./routes/accounts.routes');
const journalEntriesRoutes = require('./routes/journal-entries.routes');
const configurationRoutes = require('./routes/configuration.routes');
const ledgerRoutes = require('./routes/ledger.routes');
const trialBalanceRoutes = require('./routes/trial-balance.routes');

const { authenticateToken, allowRoles } = require('./middlewares/auth.middleware');
const pool = require('./db');

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

async function findMasterUserByEmail(email) {
  const [rows] = await pool.query(
    `SELECT id, email, password_hash, is_active
     FROM master_users
     WHERE LOWER(email) = LOWER(?)
     LIMIT 1`,
    [email]
  );

  return rows.length > 0 ? rows[0] : null;
}

async function findOfficeUserByEmail(email) {
  const [rows] = await pool.query(
    `SELECT id, office_id, username, name, email, password_hash, role, status
     FROM office_users
     WHERE LOWER(email) = LOWER(?)
     LIMIT 1`,
    [email]
  );

  return rows.length > 0 ? rows[0] : null;
}

app.post('/api/login', async (req, res) => {
  try {
    const { email, password } = req.body || {};
    const cleanEmail = String(email || '').trim().toLowerCase();

    if (!cleanEmail || !password) {
      return res.status(400).json({
        message: 'Email y password son obligatorios'
      });
    }

    let user = await findMasterUserByEmail(cleanEmail);
    let isMaster = true;

    if (!user) {
      user = await findOfficeUserByEmail(cleanEmail);
      isMaster = false;
    }

    if (!user) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }

    if (isMaster && !Number(user.is_active)) {
      return res.status(403).json({ message: 'Usuario inactivo' });
    }

    if (!isMaster && Number(user.status) !== 1) {
      return res.status(403).json({ message: 'Usuario inactivo' });
    }

    const ok = bcrypt.compareSync(
      password,
      String(user.password_hash || '').trim()
    );

    if (!ok) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }

    let role = 'MASTER';
    let scope = 'master';

    if (!isMaster) {
      role = String(user.role || 'OFFICE_USER').trim().toUpperCase();
      scope = role === 'OFFICE_ADMIN' ? 'office_admin' : 'office_user';
    }

    const tokenPayload = {
      id: user.id,
      email: user.email,
      role,
      scope
    };

    if (!isMaster) {
      tokenPayload.office_id = user.office_id;
      tokenPayload.username = user.username;
      tokenPayload.name = user.name;
    }

    const token = jwt.sign(
      tokenPayload,
      process.env.JWT_SECRET,
      { expiresIn: '8h' }
    );

    return res.json({
      token,
      user: {
        id: user.id,
        office_id: isMaster ? null : user.office_id,
        username: isMaster ? null : user.username,
        name: isMaster ? null : user.name,
        email: user.email,
        role,
        scope
      }
    });

  } catch (err) {
    console.error('LOGIN ERROR:', err);
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
});

const companiesRouter = companiesRoutes(pool);
const officeUsersRouter = officeUsersRoutes(pool);
const accountsRouter = accountsRoutes(pool);
const journalEntriesRouter = journalEntriesRoutes(pool, authenticateToken);
const configurationRouter = configurationRoutes(pool);

app.use('/api/companies', companiesRouter);
app.use('/api/office-users', officeUsersRouter);
app.use('/api/accounts', accountsRouter);
app.use('/api/journal-entries', journalEntriesRouter);
app.use('/api/configuration', configurationRouter);

app.use('/api', ledgerRoutes);
app.use('/api/reports', trialBalanceRoutes);

app.use(
  '/api/master/offices',
  authenticateToken,
  allowRoles('MASTER'),
  officesRoutesFactory(pool)
);

app.use(express.static(path.join(__dirname, '../public')));

app.get(/.*/, (req, res) => {
  res.sendFile(path.join(__dirname, '../public/index.html'));
});

const PORT = Number(process.env.PORT) || 3000;

app.listen(PORT, () => {
  console.log(`Master API corriendo en puerto ${PORT}`);
});