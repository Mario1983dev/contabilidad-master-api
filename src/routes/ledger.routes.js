const express = require('express');
const PDFDocument = require('pdfkit');
const router = express.Router();
const pool = require('../db');

async function getLedgerData(company_id, account_id, fromDate, toDate) {
  const [rows] = await pool.query(
    `
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
      AND je.status = 1
    ORDER BY je.entry_date ASC, je.id ASC, jel.id ASC
    `,
    [company_id, account_id, fromDate, toDate]
  );

  let saldo = 0;

  return rows.map((row) => {
    const debit = Number(row.debit || 0);
    const credit = Number(row.credit || 0);
    saldo += debit - credit;

    return {
      ...row,
      debit,
      credit,
      saldo
    };
  });
}

function formatDate(value) {
  if (!value) return '';

  const date = new Date(value);

  return date.toLocaleDateString('es-CL', {
    timeZone: 'UTC'
  });
}

function formatMoney(value) {
  return Number(value || 0).toLocaleString('es-CL');
}

router.get('/', async (req, res) => {
  try {
    const { company_id, account_id, fromDate, toDate } = req.query;

    if (!company_id || !account_id || !fromDate || !toDate) {
      return res.status(400).json({
        message: 'Faltan parámetros: company_id, account_id, fromDate, toDate'
      });
    }

    const data = await getLedgerData(company_id, account_id, fromDate, toDate);

    return res.json(data);
  } catch (error) {
    console.error('Error al obtener libro mayor:', error);

    return res.status(500).json({
      message: 'Error interno del servidor'
    });
  }
});

router.get('/pdf', async (req, res) => {
  try {
    const { company_id, account_id, fromDate, toDate } = req.query;

    if (!company_id || !account_id || !fromDate || !toDate) {
      return res.status(400).json({
        message: 'Faltan parámetros: company_id, account_id, fromDate, toDate'
      });
    }

    const ledger = await getLedgerData(company_id, account_id, fromDate, toDate);

    const [companyRows] = await pool.query(
      `
      SELECT 
        legal_name,
        name,
        rut,
        address,
        commune,
        city
      FROM companies
      WHERE id = ?
      LIMIT 1
      `,
      [company_id]
    );

    const company = companyRows[0] || {};

    const doc = new PDFDocument({
      size: 'A4',
      margin: 35
    });

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader(
      'Content-Disposition',
      `inline; filename=libro-mayor-${fromDate}-${toDate}.pdf`
    );

    doc.pipe(res);

    doc.fontSize(14).font('Helvetica-Bold').text(
      company.legal_name || company.name || 'Empresa',
      { align: 'center' }
    );

    if (company.rut) {
      doc.fontSize(9).font('Helvetica').text(`RUT: ${company.rut}`, {
        align: 'center'
      });
    }

    if (company.address || company.commune || company.city) {
      doc.fontSize(8).text(
        `${company.address || ''} ${company.commune || ''} ${company.city || ''}`,
        { align: 'center' }
      );
    }

    doc.moveDown(0.6);

    doc.fontSize(16).font('Helvetica-Bold').text('LIBRO MAYOR', {
      align: 'center',
      underline: true
    });

    doc.moveDown(0.6);

    doc.fontSize(9).font('Helvetica');
    doc.text(`Periodo: ${formatDate(fromDate)} al ${formatDate(toDate)}`);

    if (ledger.length > 0) {
      doc.text(`Cuenta: ${ledger[0].account_code} - ${ledger[0].account_name}`);
    } else {
      doc.text('Cuenta: Sin movimientos en el periodo');
    }

    doc.moveDown();

    const startX = 35;
    let y = doc.y;

    const col = {
      fecha: startX,
      asiento: 85,
      glosa: 135,
      debe: 330,
      haber: 405,
      saldo: 480
    };

    function drawHeader() {
      doc.fontSize(8).font('Helvetica-Bold');

      doc.text('Fecha', col.fecha, y, { width: 45 });
      doc.text('Asiento', col.asiento, y, { width: 45 });
      doc.text('Glosa', col.glosa, y, { width: 180 });
      doc.text('Debe', col.debe, y, { width: 65, align: 'right' });
      doc.text('Haber', col.haber, y, { width: 65, align: 'right' });
      doc.text('Saldo', col.saldo, y, { width: 65, align: 'right' });

      y += 15;
      doc.moveTo(startX, y).lineTo(560, y).stroke();
      y += 8;

      doc.font('Helvetica');
    }

    drawHeader();

    let totalDebe = 0;
    let totalHaber = 0;

    ledger.forEach((row) => {
      if (y > 760) {
        doc.addPage();
        y = 40;
        drawHeader();
      }

      totalDebe += row.debit;
      totalHaber += row.credit;

      const glosa = row.line_description || row.entry_description || '';

      doc.fontSize(8).font('Helvetica');

      doc.text(formatDate(row.entry_date), col.fecha, y, { width: 45 });
      doc.text(String(row.entry_id), col.asiento, y, { width: 45 });
      doc.text(glosa, col.glosa, y, { width: 180 });
      doc.text(formatMoney(row.debit), col.debe, y, { width: 65, align: 'right' });
      doc.text(formatMoney(row.credit), col.haber, y, { width: 65, align: 'right' });
      doc.text(formatMoney(row.saldo), col.saldo, y, { width: 65, align: 'right' });

      y += 18;
    });

    y += 5;
    doc.moveTo(startX, y).lineTo(560, y).stroke();
    y += 10;

    doc.fontSize(8).font('Helvetica-Bold');
    doc.text('Totales', col.glosa, y, { width: 180 });
    doc.text(formatMoney(totalDebe), col.debe, y, { width: 65, align: 'right' });
    doc.text(formatMoney(totalHaber), col.haber, y, { width: 65, align: 'right' });
    doc.text(formatMoney(totalDebe - totalHaber), col.saldo, y, {
      width: 65,
      align: 'right'
    });

    doc.end();
  } catch (error) {
    console.error('Error al generar PDF libro mayor:', error);

    return res.status(500).json({
      message: 'Error interno al generar PDF'
    });
  }
});

module.exports = router;