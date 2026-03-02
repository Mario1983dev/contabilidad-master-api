require('dotenv').config();

const express = require('express');
const cors = require('cors');
const pool = require('./db');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const app = express();

app.use(cors());
app.use(express.json());

/* ======================================================
   ROOT
====================================================== */
app.get('/', (req, res) => {
  res.json({ message: 'Contabilidad Master API funcionando' });
});

/* ======================================================
   LOGIN MASTER
====================================================== */
app.post('/auth/login', async (req, res) => {
  try {
    const { email, password } = req.body || {};

    if (!email || !password) {
      return res.status(400).json({ message: 'Email y password son obligatorios' });
    }

    const [rows] = await pool.query(
      'SELECT id, email, password_hash, is_active FROM master_users WHERE email = ? LIMIT 1',
      [email]
    );

    if (!rows || rows.length === 0) {
      return res.status(401).json({ message: 'Credenciales inválidas' });
    }

    const user = rows[0];

    if (!user.is_active) {
      return res.status(403).json({ message: 'Usuario inactivo' });
    }

    const ok = bcrypt.compareSync(password, String(user.password_hash).trim());

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

/* ======================================================
   MIDDLEWARE JWT
====================================================== */
function verifyToken(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ message: 'Token requerido' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET || 'solusoft_secret'
    );

    req.user = decoded;
    next();

  } catch (err) {
    return res.status(401).json({ message: 'Token inválido' });
  }
}

/* ======================================================
   CREAR OFICINA (solo MASTER)
====================================================== */
app.post('/offices', verifyToken, async (req, res) => {
  try {

    if (req.user.role !== 'MASTER') {
      return res.status(403).json({ message: 'No autorizado' });
    }

    const { name } = req.body;

    if (!name) {
      return res.status(400).json({ message: 'Nombre de oficina requerido' });
    }

    const [result] = await pool.query(
      'INSERT INTO offices (name) VALUES (?)',
      [name]
    );

    res.status(201).json({
      message: 'Oficina creada',
      officeId: result.insertId
    });

  } catch (err) {
    console.error('CREATE OFFICE ERROR:', err);
    res.status(500).json({ message: 'Error interno' });
  }
});

/* ======================================================
   SERVER
====================================================== */
const PORT = process.env.PORT || 4000;

app.listen(PORT, () => {
  console.log(`Master API corriendo en puerto ${PORT}`);
});