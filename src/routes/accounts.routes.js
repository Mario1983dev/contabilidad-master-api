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

  router.post(
    '/',
    authenticateToken,
    allowRoles('MASTER', 'OFFICE_ADMIN'),
    async (req, res) => {
      try {
        const {
          company_id,
          code,
          name,
          account_type,
          balance_nature,
          parent_code,
          level_num,
          allows_entries,
          sort_order,
          notes
        } = req.body;

        const companyId = Number(company_id);
        const levelNum = Number(level_num);
        const allowsEntries = Number(allows_entries) ? 1 : 0;
        const sortOrder = Number(sort_order || 0);

        if (!companyId) {
          return res.status(400).json({
            message: 'company_id es obligatorio'
          });
        }

        if (!code || !String(code).trim()) {
          return res.status(400).json({
            message: 'El código es obligatorio'
          });
        }

        if (!name || !String(name).trim()) {
          return res.status(400).json({
            message: 'El nombre es obligatorio'
          });
        }

        if (!account_type || !String(account_type).trim()) {
          return res.status(400).json({
            message: 'account_type es obligatorio'
          });
        }

        if (!balance_nature || !String(balance_nature).trim()) {
          return res.status(400).json({
            message: 'balance_nature es obligatorio'
          });
        }

        if (!levelNum) {
          return res.status(400).json({
            message: 'level_num es obligatorio'
          });
        }

        let companyRows = [];

        if (req.user.role === 'MASTER') {
          const [rows] = await pool.query(
            `SELECT id, office_id
             FROM companies
             WHERE id = ?
             LIMIT 1`,
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

        const cleanCode = String(code).trim();
        const cleanName = String(name).trim();
        const cleanAccountType = String(account_type).trim().toUpperCase();
        const cleanBalanceNature = String(balance_nature).trim().toUpperCase();
        const cleanParentCode = parent_code && String(parent_code).trim()
          ? String(parent_code).trim()
          : null;
        const cleanNotes = notes ? String(notes).trim() : '';

        const validAccountTypes = ['ACTIVO', 'PASIVO', 'PATRIMONIO', 'INGRESO', 'GASTO'];
        const validBalanceNatures = ['DEBITO', 'CREDITO'];

        if (!validAccountTypes.includes(cleanAccountType)) {
          return res.status(400).json({
            message: 'account_type no válido'
          });
        }

        if (!validBalanceNatures.includes(cleanBalanceNature)) {
          return res.status(400).json({
            message: 'balance_nature no válido'
          });
        }

        if (cleanParentCode) {
          const [parentRows] = await pool.query(
            `SELECT id
             FROM company_accounts
             WHERE company_id = ? AND code = ?
             LIMIT 1`,
            [companyId, cleanParentCode]
          );

          if (!parentRows.length) {
            return res.status(400).json({
              message: 'La cuenta padre no existe en esta empresa'
            });
          }
        }

        const [existingRows] = await pool.query(
          `SELECT id
           FROM company_accounts
           WHERE company_id = ? AND code = ?
           LIMIT 1`,
          [companyId, cleanCode]
        );

        if (existingRows.length > 0) {
          return res.status(400).json({
            message: 'Ya existe una cuenta con ese código en esta empresa'
          });
        }

        const [result] = await pool.query(
          `INSERT INTO company_accounts (
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
          ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)`,
          [
            companyId,
            cleanCode,
            cleanName,
            cleanAccountType,
            cleanBalanceNature,
            cleanParentCode,
            levelNum,
            allowsEntries,
            sortOrder,
            cleanNotes
          ]
        );

        return res.status(201).json({
          message: 'Cuenta creada correctamente',
          id: result.insertId
        });

      } catch (error) {
        console.error('ERROR POST ACCOUNTS:', error);
        return res.status(500).json({
          message: 'Error al crear cuenta'
        });
      }
    }
  );

  return router;
};