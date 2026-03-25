const express = require('express');
const {
  authenticateToken,
  allowRoles
} = require('../middlewares/auth.middleware');

module.exports = (pool) => {
  const router = express.Router();

  router.get(
    '/',
    authenticateToken,
    allowRoles('MASTER', 'OFFICE_ADMIN', 'OFFICE_USER'),
    async (req, res) => {
      try {
        const companyId = Number(req.query.company_id);

        if (!companyId) {
          return res.status(400).json({
            message: 'company_id es obligatorio'
          });
        }

        let companyRows = [];

        if (req.user.role === 'MASTER') {
          const [rows] = await pool.query(
            `SELECT id, office_id FROM companies WHERE id = ? LIMIT 1`,
            [companyId]
          );
          companyRows = rows;
        } else {
          const [rows] = await pool.query(
            `SELECT id, office_id
             FROM companies
             WHERE id = ? AND office_id = ?
             LIMIT 1`,
            [companyId, req.user.office_id]
          );
          companyRows = rows;
        }

        if (!companyRows.length) {
          return res.status(404).json({
            message: 'Empresa no encontrada o sin acceso'
          });
        }

        const [accounts] = await pool.query(
          `SELECT
            id,
            company_id,
            code,
            name,
            account_type,
            balance_nature,
            parent_code,
            level_num,
            allows_entries,
            is_active,
            sort_order,
            notes
           FROM company_accounts
           WHERE company_id = ?
           ORDER BY sort_order ASC, code ASC`,
          [companyId]
        );

        return res.json(accounts);

      } catch (error) {
        console.error('ERROR GET ACCOUNTS:', error);
        return res.status(500).json({
          message: 'Error al obtener cuentas'
        });
      }
    }
  );

  return router;
};