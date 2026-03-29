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

  return router;
};