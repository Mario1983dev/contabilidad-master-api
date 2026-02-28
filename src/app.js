require('dotenv').config();

const express = require('express');
const cors = require('cors');
const pool = require('./db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();

app.use(cors());
app.use(express.json());

app.get('/', (req, res) => {
  res.json({ message: 'Contabilidad Master API funcionando' });
});

app.post('/auth/login', async (req, res) => {
  try {
    console.log('--- LOGIN ---');
    console.log('ENV DB_HOST:', process.env.DB_HOST);
    console.log('ENV DB_USER:', process.env.DB_USER);
    console.log('ENV DB_NAME:', process.env.DB_NAME);
    console.log('BODY:', req.body);

    const { email, password } = req.body || {};

    if (!email || !password) {
      return res.status(400).json({ message: 'Email y password son obligatorios' });
    }

    const [rows] = await pool.query(
      'SELECT id, email, password_hash, is_active FROM master_users WHERE email = ? LIMIT 1',
      [email]
    );

    console.log('rows.length =', rows?.length);

    if (!rows || rows.length === 0) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }

    const user = rows[0];

    const dbHash = String(user.password_hash ?? '').trim();
    const pass = String(password);

    console.log('DB hash len =', dbHash.length);
    console.log('DB hash =', dbHash);

    if (!user.is_active) {
      return res.status(403).json({ message: 'Usuario inactivo' });
    }

    const ok = bcrypt.compareSync(pass, dbHash);
    console.log('bcrypt ok =', ok);

    if (!ok) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: 'MASTER' },
      process.env.JWT_SECRET || 'solusoft_secret',
      { expiresIn: process.env.JWT_EXPIRES_IN || '8h' }
    );

    return res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        role: 'MASTER'
      }
    });

  } catch (err) {
    console.error('LOGIN ERROR:', err);
    return res.status(500).json({ message: 'Error interno del servidor' });
  }
});

const PORT = process.env.PORT || 4000;

app.listen(PORT, () => {
  console.log(`Master API corriendo en puerto ${PORT}`);
});