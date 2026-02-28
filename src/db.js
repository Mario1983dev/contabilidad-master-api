const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'solusoft',
  password: process.env.DB_PASS || "SoluSoft#2026",
  database: process.env.DB_NAME || 'contabilidad_master',
  waitForConnections: true,
  connectionLimit: 10,
});

module.exports = pool;