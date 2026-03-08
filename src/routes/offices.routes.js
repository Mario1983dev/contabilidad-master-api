const express = require('express');
const bcrypt = require('bcryptjs');

module.exports = (pool) => {

  const router = express.Router();

  function generarClaveTemporal() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$';
    let pass = '';
    for (let i = 0; i < 8; i++) {
      pass += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return pass;
  }

  /* ======================================================
     LISTAR
  ====================================================== */
  router.get('/', async (req, res) => {
    try {

      const [rows] = await pool.query(
        `SELECT id, rut, name, legal_name, email, phone, status, created_at, updated_at
         FROM offices
         ORDER BY id DESC`
      );

      res.json(rows);

    } catch (err) {

      console.error('LIST OFFICES ERROR:', err);
      res.status(500).json({ message: 'Error interno' });

    }
  });

  /* ======================================================
     CREAR
  ====================================================== */
  router.post('/', async (req, res) => {
    try {

      const { rut, name, legal_name, email, phone, status } = req.body || {};

      if (!rut || !name) {
        return res.status(400).json({
          message: 'rut y name son obligatorios'
        });
      }

      const [result] = await pool.query(
        `INSERT INTO offices (rut, name, legal_name, email, phone, status)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [
          rut.trim(),
          name.trim(),
          legal_name ?? null,
          email ?? null,
          phone ?? null,
          status ?? 1
        ]
      );

      const officeId = result.insertId;

      /* ======================================================
         CREAR ADMIN DE OFICINA
      ====================================================== */
      const tempPassword = generarClaveTemporal();
      const passwordHash = await bcrypt.hash(tempPassword, 10);

      const adminUser = `admin${officeId}`;

await pool.query(
  `INSERT INTO office_admins (office_id, email, password_hash, is_active)
   VALUES (?, ?, ?, 1)`,
  [officeId, adminUser + '@admin.local', passwordHash]
);

      res.status(201).json({
        message: 'Oficina creada correctamente',
        id: officeId,
        admin_user: adminUser,
        temp_password: tempPassword
      });

    } catch (err) {

      console.error('CREATE OFFICE ERROR:', err);

      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({
          message: 'RUT ya existe'
        });
      }

      res.status(500).json({ message: 'Error interno' });

    }
  });

  /* ======================================================
     OBTENER UNA
  ====================================================== */
  router.get('/:id', async (req, res) => {
    try {

      const id = Number(req.params.id);

      if (!id) {
        return res.status(400).json({
          message: 'ID inválido'
        });
      }

      const [rows] = await pool.query(
        `SELECT id, rut, name, legal_name, email, phone, status, created_at, updated_at
         FROM offices
         WHERE id = ?`,
        [id]
      );

      if (!rows.length) {
        return res.status(404).json({
          message: 'No encontrada'
        });
      }

      res.json(rows[0]);

    } catch (err) {

      console.error('GET OFFICE ERROR:', err);
      res.status(500).json({ message: 'Error interno' });

    }
  });

  /* ======================================================
     ACTUALIZAR
  ====================================================== */
  router.put('/:id', async (req, res) => {
    try {

      const id = Number(req.params.id);

      if (!id) {
        return res.status(400).json({
          message: 'ID inválido'
        });
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
          rut.trim(),
          name.trim(),
          legal_name ?? null,
          email ?? null,
          phone ?? null,
          status ?? 1,
          id
        ]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({
          message: 'No encontrada'
        });
      }

      res.json({
        message: 'Actualizada correctamente'
      });

    } catch (err) {

      console.error('UPDATE OFFICE ERROR:', err);

      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({
          message: 'RUT ya existe'
        });
      }

      res.status(500).json({ message: 'Error interno' });

    }
  });

  /* ======================================================
     CAMBIAR ESTADO
  ====================================================== */
  router.put('/:id/status', async (req, res) => {
    try {

      const id = Number(req.params.id);
      const { status } = req.body || {};

      if (!id) {
        return res.status(400).json({
          message: 'ID inválido'
        });
      }

      if (status !== 0 && status !== 1) {
        return res.status(400).json({
          message: 'Status inválido'
        });
      }

      const [result] = await pool.query(
        `UPDATE offices
         SET status = ?
         WHERE id = ?`,
        [status, id]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({
          message: 'No encontrada'
        });
      }

      res.json({
        message: status === 1
          ? 'Oficina activada correctamente'
          : 'Oficina desactivada correctamente'
      });

    } catch (err) {

      console.error('CHANGE STATUS OFFICE ERROR:', err);
      res.status(500).json({ message: 'Error interno' });

    }
  });

  /* ======================================================
     ELIMINAR (SOFT DELETE)
  ====================================================== */
  router.delete('/:id', async (req, res) => {
    try {

      const id = Number(req.params.id);

      if (!id) {
        return res.status(400).json({
          message: 'ID inválido'
        });
      }

      const [result] = await pool.query(
        `UPDATE offices
         SET status = 0
         WHERE id = ?`,
        [id]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({
          message: 'No encontrada'
        });
      }

      res.json({
        message: 'Oficina desactivada correctamente'
      });

    } catch (err) {

      console.error('DELETE OFFICE ERROR:', err);
      res.status(500).json({ message: 'Error interno' });

    }
  });

  return router;

};