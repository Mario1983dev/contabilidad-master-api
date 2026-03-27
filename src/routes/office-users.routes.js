const express = require('express');
const bcrypt = require('bcryptjs');
const {
  authenticateToken,
  allowRoles
} = require('../middlewares/auth.middleware');

module.exports = (pool) => {
  const router = express.Router();

  /* ======================================================
     LISTAR USUARIOS DE OFICINA
  ====================================================== */
  router.get(
    '/office/:officeId',
    authenticateToken,
    allowRoles('MASTER', 'OFFICE_ADMIN'),
    async (req, res) => {
      try {
        const officeId = Number(req.params.officeId);
        const userRole = String(req.user.role || '').trim().toUpperCase();

        if (
          userRole === 'OFFICE_ADMIN' &&
          officeId !== Number(req.user.office_id)
        ) {
          return res.status(403).json({
            message: 'No puedes ver usuarios de otra oficina'
          });
        }

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

        return res.json(rows);
      } catch (err) {
        console.error('LIST OFFICE USERS ERROR:', err);
        return res.status(500).json({
          message: 'Error interno al listar usuarios de oficina'
        });
      }
    }
  );

  /* ======================================================
     CREAR USUARIO
  ====================================================== */
  router.post(
    '/',
    authenticateToken,
    allowRoles('MASTER', 'OFFICE_ADMIN'),
    async (req, res) => {
      try {
        const { office_id, name, email, password, role, status } = req.body || {};
        const userRole = String(req.user.role || '').trim().toUpperCase();

        const finalOfficeId =
          userRole === 'OFFICE_ADMIN'
            ? Number(req.user.office_id)
            : Number(office_id);

        if (!finalOfficeId || !name || !email || !password) {
          return res.status(400).json({
            message: 'office_id, name, email y password son obligatorios'
          });
        }

        let normalizedRole = String(role || 'user').trim().toLowerCase();

        if (normalizedRole === 'admin') {
          normalizedRole = 'OFFICE_ADMIN';
        } else if (normalizedRole === 'user') {
          normalizedRole = 'OFFICE_USER';
        } else {
          return res.status(400).json({ message: 'Rol inválido' });
        }

        const normalizedName = String(name).trim();
        const normalizedEmail = String(email).trim().toLowerCase();
        const username = normalizedEmail.split('@')[0].trim();

        if (!username) {
          return res.status(400).json({
            message: 'No se pudo generar username desde el email'
          });
        }

        console.log('BODY CREATE USER =>', req.body);
        console.log('FINAL OFFICE ID =>', finalOfficeId);
        console.log('NORMALIZED NAME =>', normalizedName);
        console.log('NORMALIZED EMAIL =>', normalizedEmail);
        console.log('USERNAME =>', username);
        console.log('NORMALIZED ROLE =>', normalizedRole);
        console.log('STATUS =>', status ?? 1);

        const [officeRows] = await pool.query(
          `SELECT id
           FROM offices
           WHERE id = ?
           LIMIT 1`,
          [finalOfficeId]
        );

        if (!officeRows.length) {
          return res.status(400).json({
            message: 'La oficina indicada no existe'
          });
        }

        const [exists] = await pool.query(
          `SELECT id
           FROM office_users
           WHERE email = ? OR username = ?
           LIMIT 1`,
          [normalizedEmail, username]
        );

        if (exists.length > 0) {
          return res.status(400).json({
            message: 'Ya existe un usuario con ese email o username'
          });
        }

        const password_hash = await bcrypt.hash(password, 10);

        const [result] = await pool.query(
          `INSERT INTO office_users
           (office_id, name, username, email, password_hash, role, status)
           VALUES (?, ?, ?, ?, ?, ?, ?)`,
          [
            finalOfficeId,
            normalizedName,
            username,
            normalizedEmail,
            password_hash,
            normalizedRole,
            status ?? 1
          ]
        );

        return res.status(201).json({
          message: 'Usuario creado correctamente',
          id: result.insertId
        });
      } catch (err) {
        console.error('CREATE OFFICE USER ERROR:', err);
        console.error('SQL MESSAGE =>', err.sqlMessage);
        console.error('SQL CODE =>', err.code);
        console.error('SQL ERRNO =>', err.errno);
        console.error('SQL =>', err.sql);

        return res.status(500).json({
          message: 'Error interno al crear usuario'
        });
      }
    }
  );

  /* ======================================================
     ACTUALIZAR USUARIO
  ====================================================== */
  router.put(
    '/:id',
    authenticateToken,
    allowRoles('MASTER', 'OFFICE_ADMIN'),
    async (req, res) => {
      try {
        const { id } = req.params;
        const { name, email, role, status } = req.body || {};

        if (!name || !email) {
          return res.status(400).json({
            message: 'name y email son obligatorios'
          });
        }

        const [userRows] = await pool.query(
          `SELECT id, office_id
           FROM office_users
           WHERE id = ?
           LIMIT 1`,
          [id]
        );

        if (!userRows.length) {
          return res.status(404).json({ message: 'Usuario no encontrado' });
        }

        const officeUser = userRows[0];
        const userRole = String(req.user.role || '').trim().toUpperCase();

        if (
          userRole === 'OFFICE_ADMIN' &&
          Number(officeUser.office_id) !== Number(req.user.office_id)
        ) {
          return res.status(403).json({
            message: 'No puedes editar este usuario'
          });
        }

        let normalizedRole = String(role || 'user').trim().toLowerCase();

        if (normalizedRole === 'admin') {
          normalizedRole = 'OFFICE_ADMIN';
        } else if (normalizedRole === 'user') {
          normalizedRole = 'OFFICE_USER';
        } else {
          return res.status(400).json({ message: 'Rol inválido' });
        }

        const normalizedName = String(name).trim();
        const normalizedEmail = String(email).trim().toLowerCase();

        const [exists] = await pool.query(
          `SELECT id
           FROM office_users
           WHERE email = ? AND id <> ?
           LIMIT 1`,
          [normalizedEmail, id]
        );

        if (exists.length > 0) {
          return res.status(400).json({
            message: 'Ya existe otro usuario con ese email'
          });
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
            normalizedName,
            normalizedEmail,
            normalizedRole,
            status ?? 1,
            id
          ]
        );

        if (result.affectedRows === 0) {
          return res.status(404).json({ message: 'Usuario no encontrado' });
        }

        return res.json({ message: 'Usuario actualizado correctamente' });
      } catch (err) {
        console.error('UPDATE OFFICE USER ERROR:', err);
        console.error('SQL MESSAGE =>', err.sqlMessage);
        console.error('SQL CODE =>', err.code);
        console.error('SQL ERRNO =>', err.errno);
        console.error('SQL =>', err.sql);

        return res.status(500).json({
          message: 'Error interno al actualizar usuario'
        });
      }
    }
  );

  /* ======================================================
     CAMBIAR ESTADO
  ====================================================== */
  router.put(
    '/:id/status',
    authenticateToken,
    allowRoles('MASTER', 'OFFICE_ADMIN'),
    async (req, res) => {
      try {
        const { id } = req.params;
        const { status } = req.body || {};

        if (status !== 0 && status !== 1) {
          return res.status(400).json({ message: 'status debe ser 0 o 1' });
        }

        const [userRows] = await pool.query(
          `SELECT id, office_id
           FROM office_users
           WHERE id = ?
           LIMIT 1`,
          [id]
        );

        if (!userRows.length) {
          return res.status(404).json({ message: 'Usuario no encontrado' });
        }

        const officeUser = userRows[0];
        const userRole = String(req.user.role || '').trim().toUpperCase();

        if (
          userRole === 'OFFICE_ADMIN' &&
          Number(officeUser.office_id) !== Number(req.user.office_id)
        ) {
          return res.status(403).json({
            message: 'No puedes cambiar el estado de este usuario'
          });
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

        return res.json({ message: 'Estado actualizado correctamente' });
      } catch (err) {
        console.error('UPDATE OFFICE USER STATUS ERROR:', err);
        console.error('SQL MESSAGE =>', err.sqlMessage);
        console.error('SQL CODE =>', err.code);
        console.error('SQL ERRNO =>', err.errno);
        console.error('SQL =>', err.sql);

        return res.status(500).json({
          message: 'Error interno al actualizar estado'
        });
      }
    }
  );

  /* ======================================================
     CAMBIAR PASSWORD
  ====================================================== */
  router.put(
    '/:id/password',
    authenticateToken,
    allowRoles('MASTER', 'OFFICE_ADMIN'),
    async (req, res) => {
      try {
        const { id } = req.params;
        const { password } = req.body || {};

        if (!password) {
          return res.status(400).json({ message: 'password es obligatorio' });
        }

        const [userRows] = await pool.query(
          `SELECT id, office_id
           FROM office_users
           WHERE id = ?
           LIMIT 1`,
          [id]
        );

        if (!userRows.length) {
          return res.status(404).json({ message: 'Usuario no encontrado' });
        }

        const officeUser = userRows[0];
        const userRole = String(req.user.role || '').trim().toUpperCase();

        if (
          userRole === 'OFFICE_ADMIN' &&
          Number(officeUser.office_id) !== Number(req.user.office_id)
        ) {
          return res.status(403).json({
            message: 'No puedes cambiar la password de este usuario'
          });
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

        return res.json({ message: 'Password actualizada correctamente' });
      } catch (err) {
        console.error('UPDATE OFFICE USER PASSWORD ERROR:', err);
        console.error('SQL MESSAGE =>', err.sqlMessage);
        console.error('SQL CODE =>', err.code);
        console.error('SQL ERRNO =>', err.errno);
        console.error('SQL =>', err.sql);

        return res.status(500).json({
          message: 'Error interno al actualizar password'
        });
      }
    }
  );

  /* ======================================================
     ELIMINAR USUARIO
  ====================================================== */
  router.delete(
    '/:id',
    authenticateToken,
    allowRoles('MASTER', 'OFFICE_ADMIN'),
    async (req, res) => {
      try {
        const { id } = req.params;

        const [userRows] = await pool.query(
          `SELECT id, office_id
           FROM office_users
           WHERE id = ?
           LIMIT 1`,
          [id]
        );

        if (!userRows.length) {
          return res.status(404).json({ message: 'Usuario no encontrado' });
        }

        const officeUser = userRows[0];
        const userRole = String(req.user.role || '').trim().toUpperCase();

        if (
          userRole === 'OFFICE_ADMIN' &&
          Number(officeUser.office_id) !== Number(req.user.office_id)
        ) {
          return res.status(403).json({
            message: 'No puedes eliminar este usuario'
          });
        }

        const [result] = await pool.query(
          `DELETE FROM office_users
           WHERE id = ?`,
          [id]
        );

        if (result.affectedRows === 0) {
          return res.status(404).json({ message: 'Usuario no encontrado' });
        }

        return res.json({ message: 'Usuario eliminado correctamente' });
      } catch (err) {
        console.error('DELETE OFFICE USER ERROR:', err);
        console.error('SQL MESSAGE =>', err.sqlMessage);
        console.error('SQL CODE =>', err.code);
        console.error('SQL ERRNO =>', err.errno);
        console.error('SQL =>', err.sql);

        return res.status(500).json({
          message: 'Error interno al eliminar usuario'
        });
      }
    }
  );

  return router;
};