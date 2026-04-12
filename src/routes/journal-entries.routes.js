console.log('>>> CARGANDO journal-entries.routes.js');

const express = require('express');

module.exports = (pool, verifyToken) => {
  console.log('>>> ENTRANDO AL EXPORT DE journal-entries.routes.js');

  const router = express.Router();

  async function validateCompanyAccess(companyId, user) {
    if (user.role === 'MASTER') {
      const [rows] = await pool.query(
        `SELECT id, office_id
         FROM companies
         WHERE id = ?
         LIMIT 1`,
        [companyId]
      );
      return rows;
    }

    const [rows] = await pool.query(
      `SELECT id, office_id
       FROM companies
       WHERE id = ?
         AND office_id = ?
       LIMIT 1`,
      [companyId, user.office_id]
    );
    return rows;
  }

  async function validateAccountForCompany(companyId, accountId) {
    const [rows] = await pool.query(
      `SELECT id, company_id, allows_entries, is_active
       FROM company_accounts
       WHERE id = ?
         AND company_id = ?
       LIMIT 1`,
      [accountId, companyId]
    );

    if (rows.length === 0) {
      return {
        ok: false,
        message: `La cuenta ${accountId} no existe en esta empresa`
      };
    }

    if (Number(rows[0].is_active) !== 1) {
      return {
        ok: false,
        message: `La cuenta ${accountId} está inactiva`
      };
    }

    if (Number(rows[0].allows_entries) !== 1) {
      return {
        ok: false,
        message: `La cuenta ${accountId} no permite movimientos`
      };
    }

    return { ok: true };
  }

  function buildTargetDates(baseDate, repeatUntilDecember) {
    const targets = [baseDate];

    if (!repeatUntilDecember) {
      return targets;
    }

    const [yearStr, monthStr, dayStr] = baseDate.split('-');
    const year = Number(yearStr);
    const month = Number(monthStr);
    const day = Number(dayStr);

    for (let m = month + 1; m <= 12; m += 1) {
      const lastDay = new Date(year, m, 0).getDate();
      const targetDay = Math.min(day, lastDay);
      const mm = String(m).padStart(2, '0');
      const dd = String(targetDay).padStart(2, '0');
      targets.push(`${year}-${mm}-${dd}`);
    }

    return targets;
  }

  async function validateLines(lines, companyId, res) {
    if (!Array.isArray(lines) || lines.length < 2) {
      res.status(400).json({
        message: 'Debes ingresar al menos 2 líneas'
      });
      return null;
    }

    let totalDebit = 0;
    let totalCredit = 0;

    for (const line of lines) {
      const accountId = Number(line.account_id);
      const debit = Number(line.debit || 0);
      const credit = Number(line.credit || 0);

      if (!accountId) {
        res.status(400).json({
          message: 'Todas las líneas deben tener cuenta'
        });
        return null;
      }

      const accountValidation = await validateAccountForCompany(companyId, accountId);

      if (!accountValidation.ok) {
        res.status(400).json({
          message: accountValidation.message
        });
        return null;
      }

      if (debit < 0 || credit < 0) {
        res.status(400).json({
          message: 'Debe y Haber no pueden ser negativos'
        });
        return null;
      }

      if (debit > 0 && credit > 0) {
        res.status(400).json({
          message: 'Una línea no puede tener Debe y Haber al mismo tiempo'
        });
        return null;
      }

      if (debit === 0 && credit === 0) {
        res.status(400).json({
          message: 'Cada línea debe tener monto en Debe o Haber'
        });
        return null;
      }

      totalDebit += debit;
      totalCredit += credit;
    }

    if (totalDebit !== totalCredit) {
      res.status(400).json({
        message: 'El asiento no está cuadrado'
      });
      return null;
    }

    return {
      totalDebit,
      totalCredit
    };
  }

  // GET /journal-entries/types
  router.get('/types', verifyToken, async (req, res) => {
    try {
      const [rows] = await pool.query(`
        SELECT id, code, name, description, affects_balance, is_system
        FROM entry_types
        ORDER BY name
      `);

      return res.json(rows);
    } catch (error) {
      console.error('❌ ERROR GET entry types:', error);
      return res.status(500).json({
        message: 'Error al obtener tipos de asiento'
      });
    }
  });

  // GET /journal-entries?company_id=1
  router.get('/', verifyToken, async (req, res) => {
    try {
      const companyId = Number(req.query.company_id);

      if (!companyId) {
        return res.status(400).json({
          message: 'company_id es obligatorio'
        });
      }

      const companyRows = await validateCompanyAccess(companyId, req.user);

      if (companyRows.length === 0) {
        return res.status(403).json({
          message: 'No tienes acceso a esta empresa'
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
           je.created_at,
           COALESCE(SUM(jel.debit), 0) AS total_debit,
           COALESCE(SUM(jel.credit), 0) AS total_credit
         FROM journal_entries je
         LEFT JOIN journal_entry_lines jel
           ON jel.entry_id = je.id
         WHERE je.company_id = ?
           AND je.status = 1
         GROUP BY
           je.id,
           je.company_id,
           je.entry_date,
           je.entry_type,
           je.description,
           je.status,
           je.created_at
         ORDER BY je.entry_date DESC, je.id DESC`,
        [companyId]
      );

      return res.json(entries);
    } catch (error) {
      console.error('❌ ERROR GET journal-entries:', error);
      return res.status(500).json({
        message: 'Error al obtener asientos'
      });
    }
  });

  // GET /journal-entries/cash-balance?company_id=1
  router.get('/cash-balance', verifyToken, async (req, res) => {
    try {
      const companyId = Number(req.query.company_id);

      if (!companyId) {
        return res.status(400).json({
          message: 'company_id es obligatorio'
        });
      }

      const companyRows = await validateCompanyAccess(companyId, req.user);

      if (companyRows.length === 0) {
        return res.status(403).json({
          message: 'No tienes acceso a esta empresa'
        });
      }

      const [accountRows] = await pool.query(
        `SELECT id, code, name
         FROM company_accounts
         WHERE company_id = ?
           AND code = '1010101'
         LIMIT 1`,
        [companyId]
      );

      if (accountRows.length === 0) {
        return res.json({
          saldo: 0,
          account_id: null,
          account_code: '1010101'
        });
      }

      const accountId = Number(accountRows[0].id);

      const [balanceRows] = await pool.query(
        `SELECT
           COALESCE(SUM(jel.debit), 0) AS total_debe,
           COALESCE(SUM(jel.credit), 0) AS total_haber
         FROM journal_entry_lines jel
         INNER JOIN journal_entries je
           ON je.id = jel.entry_id
         WHERE je.company_id = ?
           AND jel.account_id = ?
           AND je.status = 1`,
        [companyId, accountId]
      );

      const totalDebe = Number(balanceRows[0]?.total_debe || 0);
      const totalHaber = Number(balanceRows[0]?.total_haber || 0);
      const saldo = totalDebe - totalHaber;

      return res.json({
        saldo,
        total_debe: totalDebe,
        total_haber: totalHaber,
        account_id: accountId,
        account_code: accountRows[0].code,
        account_name: accountRows[0].name
      });
    } catch (error) {
      console.error('❌ ERROR GET cash-balance:', error);
      return res.status(500).json({
        message: 'Error al calcular saldo de caja'
      });
    }
  });

  // POST /journal-entries
  router.post('/', verifyToken, async (req, res) => {
    let conn;

    try {
      const {
        company_id,
        entry_date,
        entry_type,
        description,
        lines,
        copy_until_december
      } = req.body;

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

      const companyRows = await validateCompanyAccess(companyId, req.user);

      if (companyRows.length === 0) {
        return res.status(403).json({
          message: 'No tienes acceso a esta empresa'
        });
      }

      const linesValidation = await validateLines(lines, companyId, res);
      if (!linesValidation) return;

      const targetDates = buildTargetDates(
        entry_date,
        Boolean(copy_until_december)
      );

      conn = await pool.getConnection();
      await conn.beginTransaction();

      const insertedIds = [];

      for (const targetDate of targetDates) {
        const [entryResult] = await conn.query(
          `INSERT INTO journal_entries
           (company_id, entry_date, entry_type, description, status)
           VALUES (?, ?, ?, ?, 1)`,
          [
            companyId,
            targetDate,
            String(entry_type).trim(),
            description ? String(description).trim() : ''
          ]
        );

        const journalEntryId = entryResult.insertId;
        insertedIds.push(journalEntryId);

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
      }

      await conn.commit();

      return res.status(201).json({
        message:
          targetDates.length > 1
            ? 'Asientos guardados correctamente hasta diciembre'
            : 'Asiento guardado correctamente',
        id: insertedIds[0],
        ids: insertedIds,
        total_created: insertedIds.length
      });
    } catch (error) {
      if (conn) {
        await conn.rollback();
      }

      console.error('❌ ERROR POST journal-entries:', error);
      return res.status(500).json({
        message: 'Error al guardar asiento'
      });
    } finally {
      if (conn) {
        conn.release();
      }
    }
  });

  // PUT /journal-entries/:id
  router.put('/:id', verifyToken, async (req, res) => {
    let conn;

    try {
      const entryId = Number(req.params.id);
      const {
        entry_date,
        entry_type,
        description,
        lines
      } = req.body;

      if (!entryId) {
        return res.status(400).json({
          message: 'id de asiento inválido'
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

      const [entryRows] = await pool.query(
        `SELECT id, company_id, status
         FROM journal_entries
         WHERE id = ?
         LIMIT 1`,
        [entryId]
      );

      if (entryRows.length === 0) {
        return res.status(404).json({
          message: 'Asiento no encontrado'
        });
      }

      const entry = entryRows[0];

      if (Number(entry.status) !== 1) {
        return res.status(400).json({
          message: 'No se puede actualizar un asiento anulado'
        });
      }

      const companyRows = await validateCompanyAccess(Number(entry.company_id), req.user);

      if (companyRows.length === 0) {
        return res.status(403).json({
          message: 'No tienes acceso a este asiento'
        });
      }

      const linesValidation = await validateLines(lines, Number(entry.company_id), res);
      if (!linesValidation) return;

      conn = await pool.getConnection();
      await conn.beginTransaction();

      await conn.query(
        `UPDATE journal_entries
         SET entry_date = ?,
             entry_type = ?,
             description = ?
         WHERE id = ?`,
        [
          entry_date,
          String(entry_type).trim(),
          description ? String(description).trim() : '',
          entryId
        ]
      );

      await conn.query(
        `DELETE FROM journal_entry_lines
         WHERE entry_id = ?`,
        [entryId]
      );

      for (const line of lines) {
        await conn.query(
          `INSERT INTO journal_entry_lines
           (entry_id, account_id, description, debit, credit)
           VALUES (?, ?, ?, ?, ?)`,
          [
            entryId,
            Number(line.account_id),
            line.description ? String(line.description).trim() : '',
            Number(line.debit || 0),
            Number(line.credit || 0)
          ]
        );
      }

      await conn.commit();

      return res.json({
        message: 'Asiento actualizado correctamente'
      });
    } catch (error) {
      if (conn) {
        await conn.rollback();
      }

      console.error('❌ ERROR PUT journal-entry:', error);
      return res.status(500).json({
        message: 'Error al actualizar asiento'
      });
    } finally {
      if (conn) {
        conn.release();
      }
    }
  });

  // PATCH /journal-entries/:id/void
  router.patch('/:id/void', verifyToken, async (req, res) => {
    try {
      const entryId = Number(req.params.id);

      if (!entryId) {
        return res.status(400).json({
          message: 'id de asiento inválido'
        });
      }

      const [entryRows] = await pool.query(
        `SELECT id, company_id, status
         FROM journal_entries
         WHERE id = ?
         LIMIT 1`,
        [entryId]
      );

      if (entryRows.length === 0) {
        return res.status(404).json({
          message: 'Asiento no encontrado'
        });
      }

      const entry = entryRows[0];
      const companyRows = await validateCompanyAccess(Number(entry.company_id), req.user);

      if (companyRows.length === 0) {
        return res.status(403).json({
          message: 'No tienes acceso a este asiento'
        });
      }

      if (Number(entry.status) === 0) {
        return res.status(400).json({
          message: 'El asiento ya está anulado'
        });
      }

      await pool.query(
        `UPDATE journal_entries
         SET status = 0
         WHERE id = ?`,
        [entryId]
      );

      return res.json({
        message: 'Asiento anulado correctamente'
      });
    } catch (error) {
      console.error('❌ ERROR PATCH journal-entry void:', error);
      return res.status(500).json({
        message: 'Error al anular asiento'
      });
    }
  });

  // GET /journal-entries/:id
  router.get('/:id', verifyToken, async (req, res) => {
    try {
      const entryId = Number(req.params.id);

      if (!entryId) {
        return res.status(400).json({
          message: 'id de asiento inválido'
        });
      }

      const [entryRows] = await pool.query(
        `SELECT *
         FROM journal_entries
         WHERE id = ?
         LIMIT 1`,
        [entryId]
      );

      if (entryRows.length === 0) {
        return res.status(404).json({
          message: 'Asiento no encontrado'
        });
      }

      const entry = entryRows[0];
      const companyRows = await validateCompanyAccess(
        Number(entry.company_id),
        req.user
      );

      if (companyRows.length === 0) {
        return res.status(403).json({
          message: 'No tienes acceso a este asiento'
        });
      }

      const [lines] = await pool.query(
        `SELECT
           jel.id,
           jel.entry_id,
           jel.account_id,
           jel.description,
           jel.debit,
           jel.credit,
           ca.code AS account_code,
           ca.name AS account_name
         FROM journal_entry_lines jel
         LEFT JOIN company_accounts ca
           ON ca.id = jel.account_id
         WHERE jel.entry_id = ?
         ORDER BY jel.id ASC`,
        [entryId]
      );

      return res.json({
        ...entry,
        lines
      });
    } catch (error) {
      console.error('❌ ERROR GET journal-entry by id:', error);
      return res.status(500).json({
        message: 'Error al obtener asiento'
      });
    }
  });

  return router;
};