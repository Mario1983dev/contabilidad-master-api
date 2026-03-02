require('dotenv').config();
const mysql = require('mysql2/promise');

(async () => {
  try {
    console.log("ENV DB_HOST:", process.env.DB_HOST);
    console.log("ENV DB_USER:", process.env.DB_USER);
    console.log("ENV DB_NAME:", process.env.DB_NAME);

    const conn = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASS,
      database: process.env.DB_NAME,
    });

    const email = "master@solusoft.cl";

    const [rows] = await conn.query(
      "SELECT id, email, is_active, password_hash, LENGTH(password_hash) lenHash, HEX(password_hash) hexHash FROM master_users WHERE email = ? LIMIT 1",
      [email]
    );

    console.log("ROW:", rows);

    await conn.end();
  } catch (e) {
    console.error("ERROR:", e);
  }
})();