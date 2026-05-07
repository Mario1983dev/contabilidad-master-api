const express = require('express');
const router = express.Router();
const db = require('../db');
const PDFDocument = require('pdfkit');

const { authenticateToken, allowRoles } = require('../middlewares/auth.middleware');

function money(value) {
  const n = Number(value || 0);
  if (n === 0) return '';
  return n.toLocaleString('es-CL');
}

function formatDate(date) {
  if (!date) return '';
  const [y, m, d] = String(date).split('-');
  return `${d}/${m}/${y}`;
}

async function getCompany(companyId) {
  const [rows] = await db.query(
    `SELECT id, name, legal_name, rut, business_type, address, commune, city
     FROM companies
     WHERE id = ?
     LIMIT 1`,
    [companyId]
  );

  return rows[0] || null;
}

async function getTrialBalanceRows(companyId, fromDate, toDate) {
  const [rows] = await db.query(
    `
    SELECT
      ca.code AS account_code,
      ca.name AS account_name,
      ca.account_type,
      COALESCE(SUM(jel.debit), 0) AS debit,
      COALESCE(SUM(jel.credit), 0) AS credit
    FROM journal_entries je
    INNER JOIN journal_entry_lines jel ON jel.entry_id = je.id
    INNER JOIN company_accounts ca ON ca.id = jel.account_id
    WHERE je.company_id = ?
      AND ca.company_id = ?
      AND je.entry_date BETWEEN ? AND ?
      AND je.status = 1
    GROUP BY ca.id, ca.code, ca.name, ca.account_type
    ORDER BY ca.code ASC
    `,
    [companyId, companyId, fromDate, toDate]
  );

  return rows;
}

function mapBalanceRows(rows) {
  return rows.map((r) => {
    const debit = Number(r.debit || 0);
    const credit = Number(r.credit || 0);
    const saldo = debit - credit;
    const type = String(r.account_type || '').toUpperCase();

    const row = {
      ...r,
      debit,
      credit,
      saldo_deudor: saldo > 0 ? saldo : 0,
      saldo_acreedor: saldo < 0 ? Math.abs(saldo) : 0,
      activo: 0,
      pasivo: 0,
      perdida: 0,
      ganancia: 0
    };

    if (type === 'ACTIVO') row.activo = row.saldo_deudor;
    else if (type === 'PASIVO' || type === 'PATRIMONIO') row.pasivo = row.saldo_acreedor;
    else if (type === 'GASTO') row.perdida = row.saldo_deudor;
    else if (type === 'INGRESO') row.ganancia = row.saldo_acreedor;

    return row;
  });
}

router.get(
  '/',
  authenticateToken,
  allowRoles('OFFICE_ADMIN', 'OFFICE_USER'),
  async (req, res) => {
    try {
      const { company_id, from, to } = req.query;

      if (!company_id || !from || !to) {
        return res.status(400).json({ message: 'Faltan parámetros' });
      }

      const rows = await getTrialBalanceRows(company_id, from, to);
      return res.json(rows);
    } catch (error) {
      console.error(error);
      return res.status(500).json({ message: 'Error interno' });
    }
  }
);

router.get(
  '/pdf',
  authenticateToken,
  allowRoles('OFFICE_ADMIN', 'OFFICE_USER'),
  async (req, res) => {
    try {
      const { company_id, from, to } = req.query;

      if (!company_id || !from || !to) {
        return res.status(400).send('Faltan parámetros');
      }

      const company = await getCompany(company_id);
      const rawRows = await getTrialBalanceRows(company_id, from, to);
      const rows = mapBalanceRows(rawRows);

      const doc = new PDFDocument({
        size: 'A4',
        layout: 'portrait',
        margin: 25
      });

      res.setHeader('Content-Type', 'application/pdf');
      res.setHeader('Content-Disposition', 'inline; filename=balance-general.pdf');
      doc.pipe(res);

      const left = 30;
      const right = 565;
      let y = 35;

      const companyName = company?.legal_name || company?.name || 'EMPRESA';
      const rut = company?.rut || '';
      const address = [company?.address, company?.commune, company?.city].filter(Boolean).join(', ');
      const giro = company?.business_type || '';

      doc.fontSize(8).font('Helvetica-Bold');
      doc.text(companyName, left, y);
      y += 10;
      doc.text(rut, left, y);
      y += 10;
      doc.text(address, left, y, { width: 300 });

      if (giro) {
        y += 10;
        doc.text(giro, left, y, { width: 300 });
      }

      y = 110;
      doc.fontSize(13).font('Helvetica-Bold');
      doc.text('BALANCE GENERAL', left, y, { width: right - left, align: 'center' });

      y += 20;
      doc.lineWidth(0.6);
      doc.moveTo(left, y).lineTo(right, y).stroke();

      y += 10;
      doc.fontSize(8).font('Helvetica');
      doc.text(
        `Ejercicio comprendido desde ${formatDate(from)} hasta ${formatDate(to)}`,
        left,
        y,
        { width: right - left, align: 'center' }
      );

      y += 35;

      const cols = {
        code: 30,
        name: 75,
        debit: 170,
        credit: 220,
        saldoD: 270,
        saldoA: 320,
        activo: 370,
        pasivo: 420,
        perdida: 470,
        ganancia: 520
      };

      const numWidth = 45;

      doc.fontSize(5.3).font('Helvetica-Bold');

      doc.text('SALDOS', cols.saldoD + 8, y - 12, {
  align: 'center',
  width: 95
});

doc.text('INVENTARIO', cols.activo + 8, y - 12, {
  align: 'center',
  width: 95
});

doc.text('RESULTADOS', cols.perdida + 8, y - 12, {
  align: 'center',
  width: 95
});

      doc.text('CUENTA', cols.code, y);
      doc.text('NOMBRE DE CUENTA', cols.name, y);

      doc.text('DÉBITO', cols.debit, y, { align: 'right', width: numWidth });
      doc.text('CRÉDITO', cols.credit, y, { align: 'right', width: numWidth });
      doc.text('DEUDOR', cols.saldoD, y, { align: 'right', width: numWidth });
      doc.text('ACREEDOR', cols.saldoA, y, { align: 'right', width: numWidth });
      doc.text('ACTIVO', cols.activo, y, { align: 'right', width: numWidth });
      doc.text('PASIVO', cols.pasivo, y, { align: 'right', width: numWidth });
      doc.text('PÉRDIDA', cols.perdida, y, { align: 'right', width: numWidth });
      doc.text('GANANCIA', cols.ganancia, y, { align: 'right', width: numWidth });

      y += 12;
      doc.moveTo(left, y).lineTo(right, y).stroke();
      y += 8;

      doc.fontSize(5.8).font('Helvetica');

      const totals = {
        debit: 0,
        credit: 0,
        saldoD: 0,
        saldoA: 0,
        activo: 0,
        pasivo: 0,
        perdida: 0,
        ganancia: 0
      };

      rows.forEach((r) => {
        if (y > 710) {
          doc.addPage({ size: 'A4', layout: 'portrait', margin: 25 });
          y = 40;
        }

        totals.debit += r.debit;
        totals.credit += r.credit;
        totals.saldoD += r.saldo_deudor;
        totals.saldoA += r.saldo_acreedor;
        totals.activo += r.activo;
        totals.pasivo += r.pasivo;
        totals.perdida += r.perdida;
        totals.ganancia += r.ganancia;

        doc.text(String(r.account_code || ''), cols.code, y);
        doc.text(String(r.account_name || ''), cols.name, y, { width: 90 });

        doc.text(money(r.debit), cols.debit, y, { align: 'right', width: numWidth });
        doc.text(money(r.credit), cols.credit, y, { align: 'right', width: numWidth });
        doc.text(money(r.saldo_deudor), cols.saldoD, y, { align: 'right', width: numWidth });
        doc.text(money(r.saldo_acreedor), cols.saldoA, y, { align: 'right', width: numWidth });
        doc.text(money(r.activo), cols.activo, y, { align: 'right', width: numWidth });
        doc.text(money(r.pasivo), cols.pasivo, y, { align: 'right', width: numWidth });
        doc.text(money(r.perdida), cols.perdida, y, { align: 'right', width: numWidth });
        doc.text(money(r.ganancia), cols.ganancia, y, { align: 'right', width: numWidth });

        y += 12;
      });

      y += 12;
      doc.font('Helvetica-Bold').fontSize(6);

      doc.text('TOTALES', cols.name, y);

      doc.text(money(totals.debit), cols.debit, y, { align: 'right', width: numWidth });
      doc.text(money(totals.credit), cols.credit, y, { align: 'right', width: numWidth });
      doc.text(money(totals.saldoD), cols.saldoD, y, { align: 'right', width: numWidth });
      doc.text(money(totals.saldoA), cols.saldoA, y, { align: 'right', width: numWidth });
      doc.text(money(totals.activo), cols.activo, y, { align: 'right', width: numWidth });
      doc.text(money(totals.pasivo), cols.pasivo, y, { align: 'right', width: numWidth });
      doc.text(money(totals.perdida), cols.perdida, y, { align: 'right', width: numWidth });
      doc.text(money(totals.ganancia), cols.ganancia, y, { align: 'right', width: numWidth });

      y += 45;

      doc.font('Helvetica-Bold').fontSize(7);
      doc.text(
  'Se deja expresa constancia, que la contabilidad y presente Balance fueron confeccionados con los datos entregados personalmente por el contribuyente, como fidedigno.',
  left,
  y,
  {
    width: right - left,
    lineGap: 2
  }
);

y += 24;
doc.text('(Artículo 100 - Código Tributario)', left, y);

      y += 80;

      doc.moveTo(left, y).lineTo(left + 250, y).stroke();

      y += 8;
      doc.font('Helvetica-Bold').fontSize(8);
      doc.text(companyName, left, y, { width: 250, align: 'center' });

      y += 10;
      doc.text(rut, left, y, { width: 250, align: 'center' });

      y += 14;
      doc.font('Helvetica').fontSize(7);
      doc.text('Firma del contribuyente', left, y, { width: 250, align: 'center' });

      doc.end();
    } catch (error) {
      console.error(error);
      return res.status(500).send('Error PDF');
    }
  }
);

module.exports = router;