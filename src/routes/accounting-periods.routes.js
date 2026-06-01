const express = require('express');

module.exports = function accountingPeriodsRoutes(pool, authenticateToken) {
  const router = express.Router();

  const verifyToken = authenticateToken;

  async function validateCompanyAccess(companyId, user) {
    if (!user) {
      return false;
    }

    if (String(user.role || '').toUpperCase() === 'MASTER') {
      return true;
    }

    const [rows] = await pool.query(
      `SELECT id
       FROM companies
       WHERE id = ?
         AND office_id = ?
       LIMIT 1`,
      [companyId, user.office_id]
    );

    return rows.length > 0;
  }

  router.get('/', verifyToken, async (req, res) => {
    try {
      const companyId = Number(req.query.company_id);

      if (!companyId) {
        return res.status(400).json({
          message: 'company_id es obligatorio'
        });
      }

      const hasAccess = await validateCompanyAccess(companyId, req.user);

      if (!hasAccess) {
        return res.status(403).json({
          message: 'No tienes acceso a esta empresa'
        });
      }

      const [rows] = await pool.query(
        `SELECT
            id,
            company_id,
            year_num,
            status,
            is_current,
            created_at
         FROM accounting_periods
         WHERE company_id = ?
         ORDER BY year_num DESC`,
        [companyId]
      );

      return res.json(rows);
    } catch (error) {
      console.error('❌ ERROR GET accounting-periods:', error);

      return res.status(500).json({
        message: 'Error al obtener períodos contables'
      });
    }
  });

  router.post('/', verifyToken, async (req, res) => {
    try {
      const companyId = Number(req.body.company_id);
      const yearNum = Number(req.body.year_num);

      if (!companyId || !yearNum) {
        return res.status(400).json({
          message: 'Datos incompletos'
        });
      }

      const hasAccess = await validateCompanyAccess(companyId, req.user);

      if (!hasAccess) {
        return res.status(403).json({
          message: 'No tienes acceso a esta empresa'
        });
      }

      const [existsRows] = await pool.query(
        `SELECT id
         FROM accounting_periods
         WHERE company_id = ?
           AND year_num = ?
         LIMIT 1`,
        [companyId, yearNum]
      );

      if (existsRows.length > 0) {
        return res.status(400).json({
          message: 'El período ya existe'
        });
      }

      await pool.query(
        `INSERT INTO accounting_periods
         (company_id, year_num, status, is_current)
         VALUES (?, ?, 'OPEN', 0)`,
        [companyId, yearNum]
      );

      return res.json({
        message: 'Período creado correctamente'
      });
    } catch (error) {
      console.error('❌ ERROR POST accounting-periods:', error);

      return res.status(500).json({
        message: 'Error al crear período'
      });
    }
  });

  router.put('/:id', verifyToken, async (req, res) => {
    let conn;

    try {
      const periodId = Number(req.params.id);
      const status = String(req.body.status || '').trim().toUpperCase();

      const validStatuses = ['OPEN', 'CLOSED', 'CURRENT'];

      if (!periodId) {
        return res.status(400).json({
          message: 'Id de período inválido'
        });
      }

      if (!validStatuses.includes(status)) {
        return res.status(400).json({
          message: 'Estado de período inválido'
        });
      }

      const [periodRows] = await pool.query(
        `SELECT id, company_id, year_num
         FROM accounting_periods
         WHERE id = ?
         LIMIT 1`,
        [periodId]
      );

      if (periodRows.length === 0) {
        return res.status(404).json({
          message: 'Período no encontrado'
        });
      }

      const period = periodRows[0];

      const hasAccess = await validateCompanyAccess(
        Number(period.company_id),
        req.user
      );

      if (!hasAccess) {
        return res.status(403).json({
          message: 'No tienes acceso a este período'
        });
      }

      conn = await pool.getConnection();
      await conn.beginTransaction();

      if (status === 'CURRENT') {
        await conn.query(
          `UPDATE accounting_periods
           SET is_current = 0
           WHERE company_id = ?`,
          [period.company_id]
        );

        await conn.query(
          `UPDATE accounting_periods
           SET status = 'OPEN',
               is_current = 1
           WHERE id = ?`,
          [periodId]
        );
      }

      if (status === 'CLOSED') {
        await conn.query(
          `UPDATE accounting_periods
           SET status = 'CLOSED',
               is_current = 0
           WHERE id = ?`,
          [periodId]
        );
      }

      if (status === 'OPEN') {
        await conn.query(
          `UPDATE accounting_periods
           SET status = 'OPEN'
           WHERE id = ?`,
          [periodId]
        );
      }

      await conn.commit();

      return res.json({
        message: 'Período actualizado correctamente'
      });
    } catch (error) {
      if (conn) {
        await conn.rollback();
      }

      console.error('❌ ERROR PUT accounting-periods:', error);

      return res.status(500).json({
        message: 'Error al actualizar período contable'
      });
    } finally {
      if (conn) {
        conn.release();
      }
    }
  });

  return router;
};