const express = require('express');

module.exports = (pool, verifyToken) => {
  const router = express.Router();

  async function validateCompanyAccess(companyId, user) {
    if (user.role === 'MASTER') {
      const [rows] = await pool.query(
        `SELECT id FROM companies WHERE id = ? LIMIT 1`,
        [companyId]
      );
      return rows.length > 0;
    }

    const [rows] = await pool.query(
      `SELECT id FROM companies
       WHERE id = ? AND office_id = ?
       LIMIT 1`,
      [companyId, user.office_id]
    );

    return rows.length > 0;
  }

  // GET /accounting-periods?company_id=1
  router.get('/', verifyToken, async (req, res) => {
    try {
      const companyId = Number(req.query.company_id);

      if (!companyId) {
        return res.status(400).json({ message: 'company_id es obligatorio' });
      }

      const hasAccess = await validateCompanyAccess(companyId, req.user);

      if (!hasAccess) {
        return res.status(403).json({ message: 'No tienes acceso a esta empresa' });
      }

      const [rows] = await pool.query(
        `SELECT id, company_id, year_num, start_date, end_date, status, notes
         FROM accounting_periods
         WHERE company_id = ?
         ORDER BY year_num DESC`,
        [companyId]
      );

      return res.json(rows);
    } catch (error) {
      console.error('❌ ERROR GET accounting-periods:', error);
      return res.status(500).json({ message: 'Error al obtener períodos contables' });
    }
  });

  // POST /accounting-periods
  router.post('/', verifyToken, async (req, res) => {
    try {
      const companyId = Number(req.body.company_id);
      const yearNum = Number(req.body.year_num);

      if (!companyId) {
        return res.status(400).json({ message: 'company_id es obligatorio' });
      }

      if (!yearNum || yearNum < 2000 || yearNum > 2100) {
        return res.status(400).json({ message: 'Año inválido' });
      }

      const hasAccess = await validateCompanyAccess(companyId, req.user);

      if (!hasAccess) {
        return res.status(403).json({ message: 'No tienes acceso a esta empresa' });
      }

      const [exists] = await pool.query(
        `SELECT id FROM accounting_periods
         WHERE company_id = ? AND year_num = ?
         LIMIT 1`,
        [companyId, yearNum]
      );

      if (exists.length > 0) {
        return res.status(400).json({
          message: `El período ${yearNum} ya existe para esta empresa`
        });
      }

      await pool.query(
        `INSERT INTO accounting_periods
         (company_id, year_num, start_date, end_date, status, notes)
         VALUES (?, ?, ?, ?, 'OPEN', ?)`,
        [
          companyId,
          yearNum,
          `${yearNum}-01-01`,
          `${yearNum}-12-31`,
          'Período creado manualmente'
        ]
      );

      return res.status(201).json({
        message: 'Período creado correctamente'
      });
    } catch (error) {
      console.error('❌ ERROR POST accounting-periods:', error);
      return res.status(500).json({ message: 'Error al crear período contable' });
    }
  });

  // PUT /accounting-periods/:id
  router.put('/:id', verifyToken, async (req, res) => {
    let conn;

    try {
      const periodId = Number(req.params.id);
      const status = String(req.body.status || '').trim().toUpperCase();

      const validStatuses = ['OPEN', 'CURRENT', 'CLOSED'];

      if (!periodId) {
        return res.status(400).json({ message: 'id de período inválido' });
      }

      if (!validStatuses.includes(status)) {
        return res.status(400).json({ message: 'Estado de período inválido' });
      }

      const [periodRows] = await pool.query(
        `SELECT id, company_id, year_num
         FROM accounting_periods
         WHERE id = ?
         LIMIT 1`,
        [periodId]
      );

      if (periodRows.length === 0) {
        return res.status(404).json({ message: 'Período no encontrado' });
      }

      const period = periodRows[0];

      const hasAccess = await validateCompanyAccess(Number(period.company_id), req.user);

      if (!hasAccess) {
        return res.status(403).json({ message: 'No tienes acceso a este período' });
      }

      conn = await pool.getConnection();
      await conn.beginTransaction();

      if (status === 'CURRENT') {
        await conn.query(
          `UPDATE accounting_periods
           SET status = 'OPEN'
           WHERE company_id = ?
             AND status = 'CURRENT'
             AND id <> ?`,
          [period.company_id, periodId]
        );
      }

      await conn.query(
        `UPDATE accounting_periods
         SET status = ?
         WHERE id = ?`,
        [status, periodId]
      );

      await conn.commit();

      return res.json({
        message: 'Período actualizado correctamente'
      });
    } catch (error) {
      if (conn) await conn.rollback();

      console.error('❌ ERROR PUT accounting-periods:', error);
      return res.status(500).json({ message: 'Error al actualizar período contable' });
    } finally {
      if (conn) conn.release();
    }
  });

  return router;
};