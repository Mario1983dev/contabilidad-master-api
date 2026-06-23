const express = require('express');
const router = express.Router();
const pool = require('../db');

router.get('/test', (req, res) => {
  res.json({
    message: 'Modulo Libros Compras y Ventas funcionando'
  });
});

router.get('/', async (req, res) => {
  try {
    const { company_id, periodo, tipo_libro } = req.query;

    if (!company_id) {
      return res.status(400).json({
        message: 'Debe indicar la empresa'
      });
    }

    let sql = `
      SELECT
        id,
        company_id,
        periodo,
        tipo_libro,
        archivo_nombre
      FROM libro_cv
      WHERE company_id = ?
    `;

    const params = [Number(company_id)];

    if (periodo) {
      sql += ` AND periodo = ?`;
      params.push(periodo);
    }

    if (tipo_libro) {
      sql += ` AND tipo_libro = ?`;
      params.push(tipo_libro);
    }

    sql += ` ORDER BY periodo DESC, id DESC`;

    const [rows] = await pool.query(sql, params);

    return res.json(rows);

  } catch (error) {

    console.error('LIBROS CV LIST ERROR:', error);

    return res.status(500).json({
      message: 'Error al listar libros de compras y ventas'
    });
  }
});


router.get('/summary/monthly', async (req, res) => {
  try {

    const { company_id, periodo } = req.query;

    if (!company_id) {
      return res.status(400).json({
        message: 'Debe indicar la empresa'
      });
    }

    if (!periodo) {
      return res.status(400).json({
        message: 'Debe indicar el período'
      });
    }

    const [rows] = await pool.query(
      `
      SELECT
        lc.tipo_libro,
        SUM(lcd.total_documentos) total_documentos,
        SUM(lcd.monto_exento) monto_exento,
        SUM(lcd.monto_neto) monto_neto,
        SUM(lcd.iva_recuperable) iva_recuperable,
        SUM(lcd.monto_iva) monto_iva,
        SUM(lcd.monto_total) monto_total
      FROM libro_cv lc
      INNER JOIN libro_cv_detalle lcd
        ON lcd.libro_cv_id = lc.id
      WHERE lc.company_id = ?
        AND lc.periodo = ?
      GROUP BY lc.tipo_libro
      `,
      [Number(company_id), periodo]
    );

    const compras = rows.find(r => r.tipo_libro === 'COMPRA') || {};
    const ventas = rows.find(r => r.tipo_libro === 'VENTA') || {};

    const ivaCredito = Number(compras.iva_recuperable || compras.monto_iva || 0);
    const ivaDebito = Number(ventas.monto_iva || 0);

    const diferencia = ivaDebito - ivaCredito;

    return res.json({
      company_id: Number(company_id),
      periodo,

      compras: {
        documentos: Number(compras.total_documentos || 0),
        exento: Number(compras.monto_exento || 0),
        neto: Number(compras.monto_neto || 0),
        iva_credito: ivaCredito,
        total: Number(compras.monto_total || 0)
      },

      ventas: {
        documentos: Number(ventas.total_documentos || 0),
        exento: Number(ventas.monto_exento || 0),
        neto: Number(ventas.monto_neto || 0),
        iva_debito: ivaDebito,
        total: Number(ventas.monto_total || 0)
      },

      resultado: {
        iva_debito: ivaDebito,
        iva_credito: ivaCredito,
        diferencia,
        tipo: diferencia >= 0
          ? 'IVA_POR_PAGAR'
          : 'IVA_REMANENTE'
      }
    });

  } catch (error) {

    console.error('LIBROS CV SUMMARY ERROR:', error);

    return res.status(500).json({
      message: 'Error al obtener resumen IVA mensual'
    });
  }
});


router.get('/:id', async (req, res) => {
  try {

    const libroId = Number(req.params.id);

    if (!libroId) {
      return res.status(400).json({
        message: 'Libro inválido'
      });
    }

    const [libroRows] = await pool.query(
      `
      SELECT
        id,
        company_id,
        periodo,
        tipo_libro,
        archivo_nombre
      FROM libro_cv
      WHERE id = ?
      `,
      [libroId]
    );

    if (!libroRows.length) {
      return res.status(404).json({
        message: 'Libro no encontrado'
      });
    }

    const [detalleRows] = await pool.query(
      `
      SELECT
        id,
        libro_cv_id,
        tipo_documento,
        total_documentos,
        monto_exento,
        monto_neto,
        iva_recuperable,
        iva_uso_comun,
        iva_no_recuperable,
        monto_iva,
        monto_total
      FROM libro_cv_detalle
      WHERE libro_cv_id = ?
      ORDER BY id ASC
      `,
      [libroId]
    );

    return res.json({
      libro: libroRows[0],
      detalle: detalleRows
    });

  } catch (error) {

    console.error('LIBROS CV DETAIL ERROR:', error);

    return res.status(500).json({
      message: 'Error al obtener detalle del libro'
    });
  }
});

module.exports = router;