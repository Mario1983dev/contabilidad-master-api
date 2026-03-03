const express = require('express');

module.exports = (pool) => {
  const router = express.Router();

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
        return res.status(400).json({ message: 'rut y name son obligatorios' });
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

      res.status(201).json({
        message: 'Oficina creada',
        id: result.insertId
      });

    } catch (err) {
      console.error('CREATE OFFICE ERROR:', err);

      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ message: 'RUT ya existe' });
      }

      res.status(500).json({ message: 'Error interno' });
    }
  });

  /* ======================================================
     OBTENER 1
  ====================================================== */
  router.get('/:id', async (req, res) => {
    try {
      const id = Number(req.params.id);
      if (!id) return res.status(400).json({ message: 'ID inválido' });

      const [rows] = await pool.query(
        `SELECT id, rut, name, legal_name, email, phone, status, created_at, updated_at
         FROM offices
         WHERE id = ?`,
        [id]
      );

      if (!rows.length) {
        return res.status(404).json({ message: 'No encontrada' });
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
      if (!id) return res.status(400).json({ message: 'ID inválido' });

      const { rut, name, legal_name, email, phone, status } = req.body || {};

      if (!rut || !name) {
        return res.status(400).json({ message: 'rut y name son obligatorios' });
      }

      const [result] = await pool.query(
        `UPDATE offices
         SET rut=?, name=?, legal_name=?, email=?, phone=?, status=?
         WHERE id=?`,
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
        return res.status(404).json({ message: 'No encontrada' });
      }

      res.json({ message: 'Actualizada correctamente' });

    } catch (err) {
      console.error('UPDATE OFFICE ERROR:', err);

      if (err.code === 'ER_DUP_ENTRY') {
        return res.status(409).json({ message: 'RUT ya existe' });
      }

      res.status(500).json({ message: 'Error interno' });
    }
  });

  /* ======================================================
     DESACTIVAR (soft delete)
  ====================================================== */
  router.delete('/:id', async (req, res) => {
    try {
      const id = Number(req.params.id);
      if (!id) return res.status(400).json({ message: 'ID inválido' });

      const [result] = await pool.query(
        `UPDATE offices SET status = 0 WHERE id = ?`,
        [id]
      );

      if (result.affectedRows === 0) {
        return res.status(404).json({ message: 'No encontrada' });
      }

      res.json({ message: 'Desactivada correctamente' });

    } catch (err) {
      console.error('DELETE OFFICE ERROR:', err);
      res.status(500).json({ message: 'Error interno' });
    }
  });

  return router;
};