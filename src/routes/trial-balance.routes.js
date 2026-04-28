const express = require('express');
const router = express.Router();
const db = require('../db');

router.get('/trial-balance', async (req, res) => {
  try {
    const { company_id, from, to } = req.query;

    if (!company_id || !from || !to) {
      return res.status(400).json({
        message: 'Faltan parámetros: company_id, from, to'
      });
    }

    const [rows] = await db.query(
      `
      SELECT
        ca.id,
        ca.code,
        ca.name,
        ca.account_type,
        ca.balance_nature,

        COALESCE(SUM(CASE WHEN je.id IS NOT NULL THEN jel.debit ELSE 0 END), 0) AS total_debit,
        COALESCE(SUM(CASE WHEN je.id IS NOT NULL THEN jel.credit ELSE 0 END), 0) AS total_credit,

        (
          COALESCE(SUM(CASE WHEN je.id IS NOT NULL THEN jel.debit ELSE 0 END), 0)
          -
          COALESCE(SUM(CASE WHEN je.id IS NOT NULL THEN jel.credit ELSE 0 END), 0)
        ) AS saldo,

        CASE
          WHEN (
            COALESCE(SUM(CASE WHEN je.id IS NOT NULL THEN jel.debit ELSE 0 END), 0)
            -
            COALESCE(SUM(CASE WHEN je.id IS NOT NULL THEN jel.credit ELSE 0 END), 0)
          ) > 0
          THEN (
            COALESCE(SUM(CASE WHEN je.id IS NOT NULL THEN jel.debit ELSE 0 END), 0)
            -
            COALESCE(SUM(CASE WHEN je.id IS NOT NULL THEN jel.credit ELSE 0 END), 0)
          )
          ELSE 0
        END AS saldo_deudor,

        CASE
          WHEN (
            COALESCE(SUM(CASE WHEN je.id IS NOT NULL THEN jel.debit ELSE 0 END), 0)
            -
            COALESCE(SUM(CASE WHEN je.id IS NOT NULL THEN jel.credit ELSE 0 END), 0)
          ) < 0
          THEN ABS(
            COALESCE(SUM(CASE WHEN je.id IS NOT NULL THEN jel.debit ELSE 0 END), 0)
            -
            COALESCE(SUM(CASE WHEN je.id IS NOT NULL THEN jel.credit ELSE 0 END), 0)
          )
          ELSE 0
        END AS saldo_acreedor

      FROM company_accounts ca
      LEFT JOIN journal_entry_lines jel
        ON jel.account_id = ca.id
      LEFT JOIN journal_entries je
        ON je.id = jel.entry_id
        AND je.company_id = ?
        AND je.entry_date BETWEEN ? AND ?

      WHERE ca.company_id = ?

      GROUP BY
        ca.id,
        ca.code,
        ca.name,
        ca.account_type,
        ca.balance_nature

      ORDER BY ca.code ASC
      `,
      [company_id, from, to, company_id]
    );

    res.json(rows);
  } catch (error) {
    console.error('Error al obtener balance:', error);
    res.status(500).json({ message: 'Error interno al obtener balance' });
  }
});

module.exports = router;