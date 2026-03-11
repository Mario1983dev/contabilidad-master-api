const express = require('express');
const bcrypt = require('bcryptjs');

module.exports = (pool) => {
  const router = express.Router();

  /* ======================================================
     LISTAR USUARIOS POR OFICINA
     GET /office-users/office/:officeId
  ====================================================== */
  router.get('/office/:officeId', async (req, res) => {
    try {
      const { officeId } = req.params;

      const [rows] = await pool.query(
        `SELECT 
           id,
           office_id,
           name,
           email,
           role,
           status,
           created_at,
           updated_at
         FROM office_users
         WHERE office_id = ?
         ORDER BY id DESC`,
        [officeId]
      );

      res.json(rows);
    } catch (err) {
      console.error('LIST OFFICE USERS ERROR:', err);
      res.status(500).json({ message: 'Error interno al listar usuarios de oficina' });
    }
  });

  /* ======================================================
     OBTENER UN USUARIO
     GET /office-users/:id
  ====================================================== */
  router.get('/:id', async (req, res) => {
    try {
      const { id } = req.params;

      const [rows] = await pool.query(
        `SELECT 
           id,
           office_id,
           name,
           email,
           role,
           status,
           created_at,
           updated_at
         FROM office_users
         WHERE id = ?
         LIMIT 1`,
        [id]
      );

      if (!rows.length) {
        return res.status(404).json({ message: 'Usuario no encontrado' });
      }

      res.json(rows[0]);
    } catch (err) {
      console.error('GET OFFICE USER ERROR:', err);
      res.status(500).json({ message: 'Error interno al obtener usuario' });
    }
  });

  /* ======================================================
     CREAR USUARIO
     POST /office-users
  ====================================================== */
  router.post('/', async (req, res) => {
    try {
      const { office_id, name, email, password, role, status } = req.body || {};

      if (!office_id || !name || !email || !password) {
        return res.status(400).json({
          message: 'office_id, name, email y password son obligatorios'
        });
      }

      const [exists] = await pool.query(
        `SELECT id
         FROM office_users
         WHERE email = ?
         LIMIT 1`,
        [email]
      );

      if (exists.length > 0) {
        return res.status(400).json({ message: 'Ya existe un usuario con ese email' });
      }

      const password_hash = await bcrypt.hash(password, 10);

      const [result] = await pool.query(
        `INSERT INTO office_users
         (office_id, name, email, password_hash, role, status)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [
          office_id,
          name,
          email,
          password_hash,
          role || 'user',
          status ?? 1
        ]
      );

      res.status(201).json({
        message: 'Usuario creado correctamente',
        id: result.insertId
      });
    } catch (err) {
      console.error('CREATE OFFICE USER ERROR:', err);
      res.status(500).json({ message: 'Error interno al crear usuario' });
    }
  });

  /* ======================================================
     ACTUALIZAR USUARIO
     PUT /office-users/:id
  ====================================================== */
  router.put('/:id', async (req, res) => {
    try {
      const { id } = req.params;
      const { name, email, role, status } = req.body || {};

      if (!name || !email) {
        return res.status(400).json({ message: 'name y email son obligatorios' });
      }

      const [exists] = await pool.query(
        `SELECT id
         FROM office_users
         WHERE email = ? AND id <> ?
         LIMIT 1`,
        [email, id]
      );

      if (exists.length > 0) {
        return res.status(400).json({ message: 'Ya existe otro usuario con ese email' });
      }

      const [result] = await pool.query(
        `UPDATE office_users
         SET
           name = ?,
           email = ?,
           role = ?,
           status = ?,
           updated_at = NOW()
         WHERE id = ?`,
        [
          name,
          email,
          role || 'user',
          status ?? 1,
          id
        ]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ message: 'Usuario no encontrado' });
      }

      res.json({ message: 'Usuario actualizado correctamente' });
    } catch (err) {
      console.error('UPDATE OFFICE USER ERROR:', err);
      res.status(500).json({ message: 'Error interno al actualizar usuario' });
    }
  });

  /* ======================================================
     CAMBIAR ESTADO
     PUT /office-users/:id/status
  ====================================================== */
  router.put('/:id/status', async (req, res) => {
    try {
      const { id } = req.params;
      const { status } = req.body || {};

      if (status !== 0 && status !== 1) {
        return res.status(400).json({ message: 'status debe ser 0 o 1' });
      }

      const [result] = await pool.query(
        `UPDATE office_users
         SET
           status = ?,
           updated_at = NOW()
         WHERE id = ?`,
        [status, id]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ message: 'Usuario no encontrado' });
      }

      res.json({ message: 'Estado actualizado correctamente' });
    } catch (err) {
      console.error('UPDATE OFFICE USER STATUS ERROR:', err);
      res.status(500).json({ message: 'Error interno al actualizar estado' });
    }
  });

  /* ======================================================
     CAMBIAR PASSWORD
     PUT /office-users/:id/password
  ====================================================== */
  router.put('/:id/password', async (req, res) => {
    try {
      const { id } = req.params;
      const { password } = req.body || {};

      if (!password) {
        return res.status(400).json({ message: 'password es obligatorio' });
      }

      const password_hash = await bcrypt.hash(password, 10);

      const [result] = await pool.query(
        `UPDATE office_users
         SET
           password_hash = ?,
           updated_at = NOW()
         WHERE id = ?`,
        [password_hash, id]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ message: 'Usuario no encontrado' });
      }

      res.json({ message: 'Password actualizada correctamente' });
    } catch (err) {
      console.error('UPDATE OFFICE USER PASSWORD ERROR:', err);
      res.status(500).json({ message: 'Error interno al actualizar password' });
    }
  });

  /* ======================================================
     ELIMINAR USUARIO
     DELETE /office-users/:id
  ====================================================== */
  router.delete('/:id', async (req, res) => {
    try {
      const { id } = req.params;

      const [result] = await pool.query(
        `DELETE FROM office_users
         WHERE id = ?`,
        [id]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ message: 'Usuario no encontrado' });
      }

      res.json({ message: 'Usuario eliminado correctamente' });
    } catch (err) {
      console.error('DELETE OFFICE USER ERROR:', err);
      res.status(500).json({ message: 'Error interno al eliminar usuario' });
    }
  });

  return router;
};