const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/ledger', async (req, res) => {
  try {
    const { company_id, account_id, fromDate, toDate } = req.query;

    if (!company_id || !account_id || !fromDate || !toDate) {
      return res.status(400).json({
        message: 'Faltan parámetros: company_id, account_id, fromDate, toDate'
      });
    }

    const [rows] = await pool.query(`
      SELECT
        je.id AS entry_id,
        je.entry_date,
        je.entry_type,
        je.description AS entry_description,
        jel.id AS line_id,
        jel.description AS line_description,
        jel.debit,
        jel.credit,
        ca.id AS account_id,
        ca.code AS account_code,
        ca.name AS account_name
      FROM journal_entry_lines jel
      INNER JOIN journal_entries je ON je.id = jel.entry_id
      INNER JOIN company_accounts ca ON ca.id = jel.account_id
      WHERE je.company_id = ?
        AND jel.account_id = ?
        AND je.entry_date BETWEEN ? AND ?
      ORDER BY je.entry_date ASC, je.id ASC, jel.id ASC
    `, [company_id, account_id, fromDate, toDate]);

    let saldo = 0;

    const data = rows.map(row => {
      const debit = Number(row.debit || 0);
      const credit = Number(row.credit || 0);
      saldo += debit - credit;

      return {
        ...row,
        saldo
      };
    });

    return res.json(data);
  } catch (error) {
    console.error('Error al obtener libro mayor:', error);
    return res.status(500).json({
      message: 'Error interno del servidor'
    });
  }
});

module.exports = router;