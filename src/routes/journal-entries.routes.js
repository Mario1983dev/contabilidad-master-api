console.log('>>> CARGANDO journal-entries.routes.js');

const express = require('express');

module.exports = (pool, verifyToken) => {
  console.log('>>> ENTRANDO AL EXPORT DE journal-entries.routes.js');

  const router = express.Router();

  // GET /journal-entries?company_id=1
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
           WHERE id = ?
             AND office_id = ?
           LIMIT 1`,
          [companyId, req.user.office_id]
        );
        companyRows = rows;
      }

      if (companyRows.length === 0) {
        return res.status(403).json({
          message: 'No tienes acceso a esta empresa'
        });
      }

      const [entries] = await pool.query(
        `SELECT *
         FROM journal_entries
         WHERE company_id = ?
         ORDER BY entry_date DESC, id DESC`,
        [companyId]
      );

      res.json(entries);
    } catch (error) {
      console.error('❌ ERROR GET journal-entries:', error);
      res.status(500).json({
        message: 'Error al obtener asientos'
      });
    }
  });

  // POST /journal-entries
  router.post('/', verifyToken, async (req, res) => {
    let conn;

    try {
      const { company_id, entry_date, entry_type, description, lines } = req.body;

      const companyId = Number(company_id);

      if (!companyId) {
        return res.status(400).json({
          message: 'company_id es obligatorio'
        });
      }

      if (!entry_date) {
        return res.status(400).json({
          message: 'entry_date es obligatorio'
        });
      }

      if (!entry_type || !String(entry_type).trim()) {
        return res.status(400).json({
          message: 'entry_type es obligatorio'
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
          [companyId]
        );
        companyRows = rows;
      } else {
        const [rows] = await pool.query(
          `SELECT id, office_id
           FROM companies
           WHERE id = ?
             AND office_id = ?
           LIMIT 1`,
          [companyId, req.user.office_id]
        );
        companyRows = rows;
      }

      if (companyRows.length === 0) {
        return res.status(403).json({
          message: 'No tienes acceso a esta empresa'
        });
      }

      let totalDebit = 0;
      let totalCredit = 0;

      for (const line of lines) {
        const accountId = Number(line.account_id);
        const debit = Number(line.debit || 0);
        const credit = Number(line.credit || 0);

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

        if (debit > 0 && credit > 0) {
          return res.status(400).json({
            message: 'Una línea no puede tener Debe y Haber al mismo tiempo'
          });
        }

        if (debit === 0 && credit === 0) {
          return res.status(400).json({
            message: 'Cada línea debe tener monto en Debe o Haber'
          });
        }

        totalDebit += debit;
        totalCredit += credit;
      }

      if (totalDebit !== totalCredit) {
        return res.status(400).json({
          message: 'El asiento no está cuadrado'
        });
      }

      conn = await pool.getConnection();
      await conn.beginTransaction();

      const [entryResult] = await conn.query(
        `INSERT INTO journal_entries
         (company_id, entry_date, entry_type, description)
         VALUES (?, ?, ?, ?)`,
        [
          companyId,
          entry_date,
          String(entry_type).trim(),
          description ? String(description).trim() : ''
        ]
      );

      const journalEntryId = entryResult.insertId;

      for (const line of lines) {
        await conn.query(
          `INSERT INTO journal_entry_lines
           (entry_id, account_id, description, debit, credit)
           VALUES (?, ?, ?, ?, ?)`,
          [
            journalEntryId,
            Number(line.account_id),
            line.description ? String(line.description).trim() : '',
            Number(line.debit || 0),
            Number(line.credit || 0)
          ]
        );
      }

      await conn.commit();

      res.status(201).json({
        message: 'Asiento guardado correctamente',
        id: journalEntryId
      });
    } catch (error) {
      if (conn) {
        await conn.rollback();
      }

      console.error('❌ ERROR POST journal-entries:', error);
      res.status(500).json({
        message: 'Error al guardar asiento'
      });
    } finally {
      if (conn) {
        conn.release();
      }
    }
  });

  return router;
};