const express = require('express');
const bcrypt = require('bcryptjs');
const {
  authenticateToken,
  allowRoles
} = require('../middlewares/auth.middleware');
console.log('RUTA STATUS CARGADA');
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
     CREAR USUARIO (CORREGIDO)
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

        // 🔴 VALIDACIÓN BASE
        if (!finalOfficeId || !name || !email || !password) {
          return res.status(400).json({
            message: 'office_id, name, email y password son obligatorios'
          });
        }

        // 🔐 VALIDACIÓN DE SEGURIDAD
        if (password.length < 6) {
          return res.status(400).json({
            message: 'La contraseña debe tener al menos 6 caracteres'
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

        const [officeRows] = await pool.query(
          `SELECT id FROM offices WHERE id = ? LIMIT 1`,
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

        // 🔥 AQUÍ ESTÁ LO IMPORTANTE: PASSWORD MANUAL
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
          `SELECT id, office_id FROM office_users WHERE id = ? LIMIT 1`,
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
          `SELECT id FROM office_users WHERE email = ? AND id <> ? LIMIT 1`,
          [normalizedEmail, id]
        );

        if (exists.length > 0) {
          return res.status(400).json({
            message: 'Ya existe otro usuario con ese email'
          });
        }

        await pool.query(
          `UPDATE office_users
           SET name = ?, email = ?, role = ?, status = ?, updated_at = NOW()
           WHERE id = ?`,
          [
            normalizedName,
            normalizedEmail,
            normalizedRole,
            status ?? 1,
            id
          ]
        );

        return res.json({ message: 'Usuario actualizado correctamente' });
      } catch (err) {
        console.error('UPDATE OFFICE USER ERROR:', err);
        return res.status(500).json({
          message: 'Error interno al actualizar usuario'
        });
      }
    }
  );

  /* ======================================================
   CAMBIAR ESTADO USUARIO
====================================================== */
router.put(
  '/:id/status',
  authenticateToken,
  allowRoles('MASTER', 'OFFICE_ADMIN'),
  async (req, res) => {
    try {
      const { id } = req.params;
      const { status } = req.body || {};

      if (![0, 1].includes(Number(status))) {
        return res.status(400).json({
          message: 'Estado inválido'
        });
      }

      const [userRows] = await pool.query(
        `SELECT id, office_id FROM office_users WHERE id = ? LIMIT 1`,
        [id]
      );

      if (!userRows.length) {
        return res.status(404).json({
          message: 'Usuario no encontrado'
        });
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

      await pool.query(
        `UPDATE office_users
         SET status = ?, updated_at = NOW()
         WHERE id = ?`,
        [Number(status), id]
      );

      return res.json({
        message: 'Estado actualizado correctamente'
      });
    } catch (err) {
      console.error('CHANGE OFFICE USER STATUS ERROR:', err);
      return res.status(500).json({
        message: 'Error interno al cambiar estado'
      });
    }
  }
);

  return router;
};