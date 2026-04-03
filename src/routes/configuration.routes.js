const express = require('express');
const {
  authenticateToken,
  allowRoles
} = require('../middlewares/auth.middleware');

module.exports = (pool) => {
  const router = express.Router();

  router.get(
    '/account-mappings',
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

        const [rows] = await pool.query(
          `SELECT
             am.id,
             am.company_id,
             am.mapping_key,
             am.account_id,
             am.notes,
             am.created_at,
             am.updated_at,
             ca.code,
             ca.name
           FROM account_mappings am
           INNER JOIN company_accounts ca
             ON ca.id = am.account_id
           WHERE am.company_id = ?
           ORDER BY am.mapping_key ASC`,
          [companyId]
        );

        return res.json(rows);
      } catch (error) {
        console.error('ERROR GET CONFIG:', error);
        return res.status(500).json({
          message: 'Error al obtener configuración'
        });
      }
    }
  );

  router.post(
    '/account-mappings',
    authenticateToken,
    allowRoles('MASTER', 'OFFICE_ADMIN'),
    async (req, res) => {
      try {
        const {
          company_id,
          mapping_key,
          account_id,
          notes
        } = req.body || {};

        const companyId = Number(company_id);
        const accountId = Number(account_id);
        const cleanKey = String(mapping_key || '').trim().toUpperCase();
        const cleanNotes = notes ? String(notes).trim() : '';

        if (!companyId) {
          return res.status(400).json({
            message: 'company_id es obligatorio'
          });
        }

        if (!cleanKey) {
          return res.status(400).json({
            message: 'mapping_key es obligatorio'
          });
        }

        if (!accountId) {
          return res.status(400).json({
            message: 'account_id es obligatorio'
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

        const allowedKeys = [
          'CAJA',
          'BANCO',
          'CLIENTES',
          'PROVEEDORES',
          'IVA_CREDITO',
          'IVA_DEBITO',
          'VENTAS',
          'COMPRAS',
          'HONORARIOS',
          'RETENCIONES',
          'DOCUMENTOS_POR_COBRAR',
          'DOCUMENTOS_POR_PAGAR'
        ];

        if (!allowedKeys.includes(cleanKey)) {
          return res.status(400).json({
            message: 'mapping_key no válido'
          });
        }

        const [accountRows] = await pool.query(
          `SELECT id, company_id
           FROM company_accounts
           WHERE id = ?
           LIMIT 1`,
          [accountId]
        );

        if (!accountRows.length) {
          return res.status(404).json({
            message: 'Cuenta no encontrada'
          });
        }

        if (Number(accountRows[0].company_id) !== companyId) {
          return res.status(400).json({
            message: 'La cuenta no pertenece a la empresa'
          });
        }

        const [existing] = await pool.query(
          `SELECT id
           FROM account_mappings
           WHERE company_id = ? AND mapping_key = ?
           LIMIT 1`,
          [companyId, cleanKey]
        );

        if (existing.length) {
          return res.status(400).json({
            message: 'Ya existe ese mapping'
          });
        }

        const [result] = await pool.query(
          `INSERT INTO account_mappings
             (company_id, mapping_key, account_id, notes)
           VALUES (?, ?, ?, ?)`,
          [companyId, cleanKey, accountId, cleanNotes]
        );

        return res.status(201).json({
          message: 'Configuración creada',
          id: result.insertId
        });
      } catch (error) {
        console.error('ERROR POST CONFIG:', error);
        return res.status(500).json({
          message: 'Error al guardar configuración'
        });
      }
    }
  );

  router.put(
    '/account-mappings/:id',
    authenticateToken,
    allowRoles('MASTER', 'OFFICE_ADMIN'),
    async (req, res) => {
      try {
        const mappingId = Number(req.params.id);
        const { account_id, notes } = req.body || {};

        const accountId = Number(account_id);
        const cleanNotes = notes ? String(notes).trim() : '';

        if (!mappingId) {
          return res.status(400).json({
            message: 'id inválido'
          });
        }

        if (!accountId) {
          return res.status(400).json({
            message: 'account_id es obligatorio'
          });
        }

        const [mappingRows] = await pool.query(
          `SELECT id, company_id, mapping_key
           FROM account_mappings
           WHERE id = ?
           LIMIT 1`,
          [mappingId]
        );

        if (!mappingRows.length) {
          return res.status(404).json({
            message: 'Configuración no encontrada'
          });
        }

        const mapping = mappingRows[0];

        let companyRows = [];

        if (req.user.role === 'MASTER') {
          const [rows] = await pool.query(
            `SELECT id, office_id
             FROM companies
             WHERE id = ?
             LIMIT 1`,
            [mapping.company_id]
          );
          companyRows = rows;
        } else {
          const [rows] = await pool.query(
            `SELECT id, office_id
             FROM companies
             WHERE id = ? AND office_id = ?
             LIMIT 1`,
            [mapping.company_id, req.user.office_id]
          );
          companyRows = rows;
        }

        if (!companyRows.length) {
          return res.status(404).json({
            message: 'Empresa no encontrada o sin acceso'
          });
        }

        const [accountRows] = await pool.query(
          `SELECT id, company_id
           FROM company_accounts
           WHERE id = ?
           LIMIT 1`,
          [accountId]
        );

        if (!accountRows.length) {
          return res.status(404).json({
            message: 'Cuenta no encontrada'
          });
        }

        if (Number(accountRows[0].company_id) !== Number(mapping.company_id)) {
          return res.status(400).json({
            message: 'La cuenta no pertenece a la empresa'
          });
        }

        await pool.query(
          `UPDATE account_mappings
           SET account_id = ?,
               notes = ?,
               updated_at = CURRENT_TIMESTAMP
           WHERE id = ?`,
          [accountId, cleanNotes, mappingId]
        );

        return res.json({
          message: 'Configuración actualizada'
        });
      } catch (error) {
        console.error('ERROR PUT CONFIG:', error);
        return res.status(500).json({
          message: 'Error al actualizar configuración'
        });
      }
    }
  );

  // ============================================
  // GET ACCOUNTING PERIOD
  // ============================================
  router.get(
    '/accounting-period',
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

        const [rows] = await pool.query(
          `SELECT *
           FROM accounting_periods
           WHERE company_id = ? AND is_current = 1
           LIMIT 1`,
          [companyId]
        );

        if (!rows.length) {
          return res.json(null);
        }

        return res.json(rows[0]);
      } catch (error) {
        console.error('ERROR GET PERIOD:', error);
        return res.status(500).json({
          message: 'Error al obtener período'
        });
      }
    }
  );

  // ============================================
  // CREATE ACCOUNTING PERIOD
  // ============================================
  router.post(
    '/accounting-period',
    authenticateToken,
    allowRoles('MASTER', 'OFFICE_ADMIN'),
    async (req, res) => {
      try {
        const { company_id, year_num, status } = req.body || {};

        const companyId = Number(company_id);
        const periodYear = Number(year_num);
        const periodStatus = String(status || 'OPEN').trim().toUpperCase();

        if (!companyId || !periodYear) {
          return res.status(400).json({
            message: 'company_id y year_num son obligatorios'
          });
        }

        if (!['OPEN', 'CLOSED'].includes(periodStatus)) {
          return res.status(400).json({
            message: 'status no válido'
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

        await pool.query(
          `UPDATE accounting_periods
           SET is_current = 0,
               updated_at = CURRENT_TIMESTAMP
           WHERE company_id = ?`,
          [companyId]
        );

        const startDate = `${periodYear}-01-01`;
        const endDate = `${periodYear}-12-31`;

        const [result] = await pool.query(
          `INSERT INTO accounting_periods
             (company_id, year_num, start_date, end_date, status, is_current, notes)
           VALUES (?, ?, ?, ?, ?, 1, ?)`,
          [
            companyId,
            periodYear,
            startDate,
            endDate,
            periodStatus,
            `Período anual ${periodYear}`
          ]
        );

        return res.status(201).json({
          message: 'Período creado correctamente',
          id: result.insertId
        });
      } catch (error) {
        console.error('ERROR CREATE PERIOD:', error);

        if (error.code === 'ER_DUP_ENTRY') {
          return res.status(409).json({
            message: 'Ya existe ese período para la empresa'
          });
        }

        return res.status(500).json({
          message: 'Error al crear período'
        });
      }
    }
  );

  // ============================================
  // UPDATE ACCOUNTING PERIOD
  // ============================================
  router.put(
    '/accounting-period/:id',
    authenticateToken,
    allowRoles('MASTER', 'OFFICE_ADMIN'),
    async (req, res) => {
      try {
        const id = Number(req.params.id);
        const { year_num, status } = req.body || {};

        const periodYear = Number(year_num);
        const periodStatus = String(status || '').trim().toUpperCase();

        if (!id) {
          return res.status(400).json({
            message: 'ID inválido'
          });
        }

        if (!periodYear) {
          return res.status(400).json({
            message: 'year_num es obligatorio'
          });
        }

        if (!['OPEN', 'CLOSED'].includes(periodStatus)) {
          return res.status(400).json({
            message: 'status no válido'
          });
        }

        const [periodRows] = await pool.query(
          `SELECT id, company_id
           FROM accounting_periods
           WHERE id = ?
           LIMIT 1`,
          [id]
        );

        if (!periodRows.length) {
          return res.status(404).json({
            message: 'Período no encontrado'
          });
        }

        const period = periodRows[0];

        let companyRows = [];

        if (req.user.role === 'MASTER') {
          const [rows] = await pool.query(
            `SELECT id
             FROM companies
             WHERE id = ?
             LIMIT 1`,
            [period.company_id]
          );
          companyRows = rows;
        } else {
          const [rows] = await pool.query(
            `SELECT id
             FROM companies
             WHERE id = ? AND office_id = ?
             LIMIT 1`,
            [period.company_id, req.user.office_id]
          );
          companyRows = rows;
        }

        if (!companyRows.length) {
          return res.status(404).json({
            message: 'Empresa no encontrada o sin acceso'
          });
        }

        const startDate = `${periodYear}-01-01`;
        const endDate = `${periodYear}-12-31`;

        await pool.query(
          `UPDATE accounting_periods
           SET year_num = ?,
               start_date = ?,
               end_date = ?,
               status = ?,
               updated_at = CURRENT_TIMESTAMP
           WHERE id = ?`,
          [periodYear, startDate, endDate, periodStatus, id]
        );

        return res.json({
          message: 'Período actualizado correctamente'
        });
      } catch (error) {
        console.error('ERROR UPDATE PERIOD:', error);

        if (error.code === 'ER_DUP_ENTRY') {
          return res.status(409).json({
            message: 'Ya existe otro período con ese año para la empresa'
          });
        }

        return res.status(500).json({
          message: 'Error al actualizar período'
        });
      }
    }
  );

  return router;
};