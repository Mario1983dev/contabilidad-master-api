const express = require('express');

module.exports = (pool, verifyToken) => {
  const router = express.Router();

  /* ======================================================
     GET /journal-entries?company_id=5
     Lista comprobantes/asientos de una empresa
  ====================================================== */
  router.get('/', verifyToken, async (req, res) => {
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

      const [entries] = await pool.query(
        `SELECT
          je.id,
          je.company_id,
          je.entry_date,
          je.entry_type,
          je.description,
          je.status,
          je.created_by,
          je.created_at,
          je.updated_at
         FROM journal_entries je
         WHERE je.company_id = ?
         ORDER BY je.entry_date DESC, je.id DESC`,
        [companyId]
      );

      res.json(entries);
    } catch (error) {
      console.error('ERROR GET JOURNAL ENTRIES:', error);
      res.status(500).json({
        message: 'Error al obtener asientos'
      });
    }
  });

  /* ======================================================
     GET /journal-entries/:id
     Obtiene encabezado + detalle
  ====================================================== */
  router.get('/:id', verifyToken, async (req, res) => {
    try {
      const entryId = Number(req.params.id);

      if (!entryId) {
        return res.status(400).json({
          message: 'id inválido'
        });
      }

      const [entryRows] = await pool.query(
        `SELECT
          je.id,
          je.company_id,
          je.entry_date,
          je.entry_type,
          je.description,
          je.status,
          je.created_by,
          je.created_at,
          je.updated_at,
          c.office_id
         FROM journal_entries je
         INNER JOIN companies c ON c.id = je.company_id
         WHERE je.id = ?
         LIMIT 1`,
        [entryId]
      );

      if (!entryRows.length) {
        return res.status(404).json({
          message: 'Asiento no encontrado'
        });
      }

      const entry = entryRows[0];

      if (
        req.user.role !== 'MASTER' &&
        Number(entry.office_id) !== Number(req.user.office_id)
      ) {
        return res.status(403).json({
          message: 'No autorizado'
        });
      }

      const [lines] = await pool.query(
        `SELECT
          jel.id,
          jel.entry_id,
          jel.account_id,
          ca.code AS account_code,
          ca.name AS account_name,
          jel.description,
          jel.debit,
          jel.credit
         FROM journal_entry_lines jel
         INNER JOIN company_accounts ca ON ca.id = jel.account_id
         WHERE jel.entry_id = ?
         ORDER BY jel.id ASC`,
        [entryId]
      );

      res.json({
        entry: {
          id: entry.id,
          company_id: entry.company_id,
          entry_date: entry.entry_date,
          entry_type: entry.entry_type,
          description: entry.description,
          status: entry.status,
          created_by: entry.created_by,
          created_at: entry.created_at,
          updated_at: entry.updated_at
        },
        lines
      });
    } catch (error) {
      console.error('ERROR GET JOURNAL ENTRY DETAIL:', error);
      res.status(500).json({
        message: 'Error al obtener detalle del asiento'
      });
    }
  });

  /* ======================================================
     POST /journal-entries
     Guarda encabezado + detalle
  ====================================================== */
  router.post('/', verifyToken, async (req, res) => {
    let connection;

    try {
      const {
        company_id,
        entry_date,
        entry_type,
        description,
        lines
      } = req.body || {};

      if (!company_id || !entry_date || !entry_type) {
        return res.status(400).json({
          message: 'company_id, entry_date y entry_type son obligatorios'
        });
      }

      if (!Array.isArray(lines) || lines.length < 2) {
        return res.status(400).json({
          message: 'Debes ingresar al menos 2 líneas'
        });
      }

      let companyRows = [];

      if (req.user.role === 'MASTER') {
        const [rows] = await pool.query(
          `SELECT id, office_id
           FROM companies
           WHERE id = ?
           LIMIT 1`,
          [company_id]
        );
        companyRows = rows;
      } else {
        const [rows] = await pool.query(
          `SELECT id, office_id
           FROM companies
           WHERE id = ? AND office_id = ?
           LIMIT 1`,
          [company_id, req.user.office_id]
        );
        companyRows = rows;
      }

      if (!companyRows.length) {
        return res.status(404).json({
          message: 'Empresa no encontrada o sin acceso'
        });
      }

      let totalDebit = 0;
      let totalCredit = 0;
      const normalizedLines = [];

      for (const line of lines) {
        const accountId = Number(line.account_id);
        const debit = Number(line.debit || 0);
        const credit = Number(line.credit || 0);
        const lineDescription = String(line.description || '').trim();

        if (!accountId) {
          return res.status(400).json({
            message: 'Todas las líneas deben tener cuenta'
          });
        }

        if (debit < 0 || credit < 0) {
          return res.status(400).json({
            message: 'Debe y Haber no pueden ser negativos'
          });
        }

        if ((debit === 0 && credit === 0) || (debit > 0 && credit > 0)) {
          return res.status(400).json({
            message: 'Cada línea debe tener valor solo en Debe o solo en Haber'
          });
        }

        totalDebit += debit;
        totalCredit += credit;

        normalizedLines.push({
          account_id: accountId,
          description: lineDescription || null,
          debit,
          credit
        });
      }

      if (Number(totalDebit.toFixed(2)) !== Number(totalCredit.toFixed(2))) {
        return res.status(400).json({
          message: 'El asiento no cuadra: Total Debe debe ser igual a Total Haber'
        });
      }

      connection = await pool.getConnection();
      await connection.beginTransaction();

      for (const line of normalizedLines) {
        const [accountRows] = await connection.query(
          `SELECT id, company_id, allows_entries, is_active
           FROM company_accounts
           WHERE id = ? AND company_id = ?
           LIMIT 1`,
          [line.account_id, company_id]
        );

        if (!accountRows.length) {
          await connection.rollback();
          return res.status(400).json({
            message: `La cuenta ${line.account_id} no pertenece a la empresa`
          });
        }

        const account = accountRows[0];

        if (!Number(account.is_active)) {
          await connection.rollback();
          return res.status(400).json({
            message: `La cuenta ${line.account_id} está inactiva`
          });
        }

        if (!Number(account.allows_entries)) {
          await connection.rollback();
          return res.status(400).json({
            message: `La cuenta ${line.account_id} no permite movimientos`
          });
        }
      }

      const [entryResult] = await connection.query(
        `INSERT INTO journal_entries (
          company_id,
          entry_date,
          entry_type,
          description,
          status,
          created_by,
          created_at,
          updated_at
        ) VALUES (?, ?, ?, ?, 'posted', ?, NOW(), NOW())`,
        [
          company_id,
          entry_date,
          String(entry_type).trim().toUpperCase(),
          String(description || '').trim() || null,
          req.user.id || null
        ]
      );

      const entryId = entryResult.insertId;

      for (const line of normalizedLines) {
        await connection.query(
          `INSERT INTO journal_entry_lines (
            entry_id,
            account_id,
            description,
            debit,
            credit
          ) VALUES (?, ?, ?, ?, ?)`,
          [
            entryId,
            line.account_id,
            line.description,
            line.debit,
            line.credit
          ]
        );
      }

      await connection.commit();

      res.status(201).json({
        message: 'Asiento creado correctamente',
        id: entryId,
        total_debit: totalDebit,
        total_credit: totalCredit
      });
    } catch (error) {
      if (connection) {
        await connection.rollback();
      }

      console.error('ERROR CREATE JOURNAL ENTRY:', error);
      res.status(500).json({
        message: 'Error al crear asiento'
      });
    } finally {
      if (connection) {
        connection.release();
      }
    }
  });

  return router;
};