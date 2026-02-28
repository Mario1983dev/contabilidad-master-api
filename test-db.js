require('dotenv').config();
const mysql = require('mysql2/promise');

(async () => {
  try {
    console.log("DB_HOST =", process.env.DB_HOST);
    console.log("DB_USER =", process.env.DB_USER);
    console.log("DB_NAME =", process.env.DB_NAME);

    const conn = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASS,
      database: process.env.DB_NAME
    });

    const [rows] = await conn.query(
      "SELECT id, email, is_active, password_hash FROM master_users WHERE email = 'master@solusoft.cl'"
    );

    console.log("ROW =", rows);

    await conn.end();
  } catch (err) {
    console.error("ERROR:", err);
  }
})();