const express = require('express');
const bcrypt = require('bcryptjs');

module.exports = (pool) => {
  const router = express.Router();

  router.get('/', async (req, res) => {
    try {
      const [rows] = await pool.query(
        `SELECT id, rut, name, legal_name, email, phone, status, created_at, updated_at
         FROM offices
         ORDER BY id DESC`
      );

      return res.json(rows);
    } catch (err) {
      console.error('LIST OFFICES ERROR:', err);
      return res.status(500).json({ message: 'Error interno' });
    }
  });

  router.post('/', async (req, res) => {
    const conn = await pool.getConnection();

    try {
      await conn.beginTransaction();

      const {
        rut,
        name,
        legal_name,
        email,
        phone,
        status,
        admin_username,
        admin_name,
        admin_email,
        admin_password
      } = req.body || {};

      if (!rut || !name) {
        await conn.rollback();
        return res.status(400).json({
          message: 'rut y name son obligatorios'
        });
      }

      if (!admin_name || !admin_email || !admin_password) {
        await conn.rollback();
        return res.status(400).json({
          message: 'Nombre, correo y contraseña del administrador son obligatorios'
        });
      }

      if (String(admin_password).trim().length < 6) {
        await conn.rollback();
        return res.status(400).json({
          message: 'La contraseña debe tener al menos 6 caracteres'
        });
      }

      const normalizedRut = String(rut).trim();
      const normalizedName = String(name).trim();
      const normalizedAdminName = String(admin_name).trim();
      const normalizedAdminEmail = String(admin_email).trim().toLowerCase();

      const normalizedAdminUsername = String(
        admin_username || admin_name
      )
        .trim()
        .toLowerCase();

      const [officeResult] = await conn.query(
        `INSERT INTO offices
         (rut, name, legal_name, email, phone, status)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [
          normalizedRut,
          normalizedName,
          legal_name || null,
          email || null,
          phone || null,
          status ?? 1
        ]
      );

      const officeId = officeResult.insertId;
      const passwordHash = await bcrypt.hash(String(admin_password).trim(), 10);

      await conn.query(
        `INSERT INTO office_users
         (office_id, username, name, email, password_hash, role, status)
         VALUES (?, ?, ?, ?, ?, 'OFFICE_ADMIN', 1)`,
        [
          officeId,
          normalizedAdminUsername,
          normalizedAdminName,
          normalizedAdminEmail,
          passwordHash
        ]
      );

      await conn.commit();

      return res.status(201).json({
        message: 'Oficina y administrador creados correctamente',
        id: officeId,
        office_id: officeId,
        admin_username: normalizedAdminUsername,
        admin_email: normalizedAdminEmail
      });
    } catch (err) {
      await conn.rollback();

      console.error('CREATE OFFICE + ADMIN ERROR:', err);

      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({
          message: 'RUT, usuario o correo ya existe'
        });
      }

      return res.status(500).json({
        message: 'Error interno al crear oficina y administrador'
      });
    } finally {
      conn.release();
    }
  });

  router.get('/:id', async (req, res) => {
    try {
      const id = Number(req.params.id);

      if (!id) {
        return res.status(400).json({ message: 'ID inválido' });
      }

      const [rows] = await pool.query(
        `SELECT id, rut, name, legal_name, email, phone, status, created_at, updated_at
         FROM offices
         WHERE id = ?`,
        [id]
      );

      if (!rows.length) {
        return res.status(404).json({ message: 'No encontrada' });
      }

      return res.json(rows[0]);
    } catch (err) {
      console.error('GET OFFICE ERROR:', err);
      return res.status(500).json({ message: 'Error interno' });
    }
  });

  router.put('/:id', async (req, res) => {
    try {
      const id = Number(req.params.id);

      if (!id) {
        return res.status(400).json({ message: 'ID inválido' });
      }

      const { rut, name, legal_name, email, phone, status } = req.body || {};

      if (!rut || !name) {
        return res.status(400).json({
          message: 'rut y name son obligatorios'
        });
      }

      const [result] = await pool.query(
        `UPDATE offices
         SET rut = ?, name = ?, legal_name = ?, email = ?, phone = ?, status = ?
         WHERE id = ?`,
        [
          String(rut).trim(),
          String(name).trim(),
          legal_name || null,
          email || null,
          phone || null,
          status ?? 1,
          id
        ]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ message: 'No encontrada' });
      }

      return res.json({ message: 'Actualizada correctamente' });
    } catch (err) {
      console.error('UPDATE OFFICE ERROR:', err);

      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ message: 'RUT ya existe' });
      }

      return res.status(500).json({ message: 'Error interno' });
    }
  });

  router.put('/:id/status', async (req, res) => {
    try {
      const id = Number(req.params.id);
      const { status } = req.body || {};

      if (!id) {
        return res.status(400).json({ message: 'ID inválido' });
      }

      if (status !== 0 && status !== 1) {
        return res.status(400).json({ message: 'Status inválido' });
      }

      const [result] = await pool.query(
        `UPDATE offices
         SET status = ?
         WHERE id = ?`,
        [status, id]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ message: 'No encontrada' });
      }

      return res.json({
        message:
          status === 1
            ? 'Oficina activada correctamente'
            : 'Oficina desactivada correctamente'
      });
    } catch (err) {
      console.error('CHANGE STATUS OFFICE ERROR:', err);
      return res.status(500).json({ message: 'Error interno' });
    }
  });

  router.delete('/:id', async (req, res) => {
    try {
      const id = Number(req.params.id);

      if (!id) {
        return res.status(400).json({ message: 'ID inválido' });
      }

      const [result] = await pool.query(
        `UPDATE offices
         SET status = 0
         WHERE id = ?`,
        [id]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ message: 'No encontrada' });
      }

      return res.json({ message: 'Oficina desactivada correctamente' });
    } catch (err) {
      console.error('DELETE OFFICE ERROR:', err);
      return res.status(500).json({ message: 'Error interno' });
    }
  });

  return router;
};