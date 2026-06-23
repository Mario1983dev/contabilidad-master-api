const express = require('express');
const router = express.Router();
const multer = require('multer');
const fs = require('fs');
const pool = require('../db');

const upload = multer({ dest: 'uploads/' });

function removeTempFile(filePath) {
  if (!filePath) return;

  fs.unlink(filePath, (err) => {
    if (err) {
      console.error('No se pudo eliminar archivo temporal:', err.message);
    }
  });
}

function parseCsvLine(line) {
  const values = [];
  let current = '';
  let insideQuotes = false;

  for (let i = 0; i < line.length; i++) {
    const char = line[i];
    const nextChar = line[i + 1];

    if (char === '"' && nextChar === '"') {
      current += '"';
      i++;
      continue;
    }

    if (char === '"') {
      insideQuotes = !insideQuotes;
      continue;
    }

    if (char === ';' && !insideQuotes) {
      values.push(current.trim());
      current = '';
      continue;
    }

    current += char;
  }

  values.push(current.trim());
  return values;
}

function normalizeText(value) {
  return String(value || '')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .trim();
}

function toNumber(value) {
  if (value === null || value === undefined || value === '') return 0;

  const cleaned = String(value)
    .replace(/\./g, '')
    .replace(/,/g, '.')
    .replace(/[^\d.-]/g, '');

  const number = Number(cleaned);
  return Number.isFinite(number) ? number : 0;
}

function getValue(row, possibleNames) {
  const keys = Object.keys(row || {});

  for (const name of possibleNames) {
    const foundKey = keys.find(
      (key) => normalizeText(key) === normalizeText(name)
    );

    if (foundKey) {
      return row[foundKey];
    }
  }

  return '';
}

function getPeriodoFromFileName(fileName) {
  const match = String(fileName || '').match(/(20\d{2})(0[1-9]|1[0-2])/);

  if (!match) return '';

  return `${match[1]}-${match[2]}`;
}

function mapDetalleRow(row) {
  return {
    tipo_documento: getValue(row, [
      'Tipo Documento',
      'Tipo Doc',
      'Tipo Docto',
      'Tipo'
    ]),
    total_documentos: toNumber(getValue(row, [
      'Total Documentos',
      'Total Documento',
      'Cantidad Documentos',
      'Cantidad'
    ])),
    monto_exento: toNumber(getValue(row, [
      'Monto Exento'
    ])),
    monto_neto: toNumber(getValue(row, [
      'Monto Neto'
    ])),
    iva_recuperable: toNumber(getValue(row, [
      'IVA Recuperable',
      'IVA Rec'
    ])),
    iva_uso_comun: toNumber(getValue(row, [
      'IVA Uso Comun',
      'IVA Uso Común'
    ])),
    iva_no_recuperable: toNumber(getValue(row, [
      'IVA No Recuperable'
    ])),
    monto_iva: toNumber(getValue(row, [
      'Monto IVA',
      'IVA',
      'IVA Rec'
    ])),
    monto_total: toNumber(getValue(row, [
      'Monto Total',
      'Total'
    ]))
  };
}

router.get('/test', (req, res) => {
  res.json({
    message: 'Modulo SII funcionando correctamente'
  });
});

router.post('/upload', upload.single('file'), (req, res) => {
  try {
    const { bookType } = req.body;

    if (!bookType) {
      removeTempFile(req.file?.path);

      return res.status(400).json({
        message: 'Debe indicar si el archivo es de COMPRAS o VENTAS'
      });
    }

    if (!req.file) {
      return res.status(400).json({
        message: 'No se recibió archivo'
      });
    }

    const content = fs.readFileSync(req.file.path, 'latin1');

    const lines = content
      .split(/\r?\n/)
      .filter((line) => line.trim() !== '');

    if (lines.length === 0) {
      removeTempFile(req.file.path);

      return res.status(400).json({
        message: 'El CSV está vacío'
      });
    }

    const headers = parseCsvLine(lines[0]).map((h) => h.trim());
    const rows = [];

    for (let i = 1; i < lines.length; i++) {
      const values = parseCsvLine(lines[i]);
      const row = {};

      headers.forEach((header, index) => {
        row[header || `columna_${index + 1}`] = values[index] || '';
      });

      rows.push(row);
    }

    removeTempFile(req.file.path);

    return res.json({
      message: 'CSV leído correctamente',
      bookType,
      totalRows: rows.length,
      preview: rows,
      file: req.file.originalname
    });
  } catch (error) {
    console.error('SII UPLOAD ERROR:', error);

    removeTempFile(req.file?.path);

    return res.status(500).json({
      message: 'Error al procesar archivo CSV'
    });
  }
});

router.post('/import', async (req, res) => {
  const connection = await pool.getConnection();

  try {
    const {
      company_id,
      bookType,
      fileName,
      totalRows,
      rows
    } = req.body;

    if (!company_id) {
      return res.status(400).json({
        message: 'Debe indicar la empresa'
      });
    }

    if (!bookType) {
      return res.status(400).json({
        message: 'Debe indicar el tipo de libro'
      });
    }

    if (!Array.isArray(rows) || rows.length === 0) {
      return res.status(400).json({
        message: 'No existen registros para importar'
      });
    }

    const periodo = getPeriodoFromFileName(fileName);

    if (!periodo) {
      return res.status(400).json({
        message: 'No se pudo determinar el período desde el nombre del archivo'
      });
    }

    const tipoLibroDb = bookType === 'COMPRAS'
      ? 'COMPRA'
      : 'VENTA';

    await connection.beginTransaction();

    const [existingBooks] = await connection.query(
      `
      SELECT id
      FROM libro_cv
      WHERE company_id = ?
        AND periodo = ?
        AND tipo_libro = ?
      LIMIT 1
      `,
      [
        Number(company_id),
        periodo,
        tipoLibroDb
      ]
    );

    if (existingBooks.length > 0) {
      await connection.rollback();

      return res.status(400).json({
        message: `El libro ${tipoLibroDb} del período ${periodo} ya fue importado.`,
        duplicated: true,
        existingLibroCvId: existingBooks[0].id,
        company_id: Number(company_id),
        periodo,
        tipoLibroDb,
        totalRows: Number(totalRows || rows.length),
        importedRows: 0,
        duplicatedRows: rows.length,
        errorRows: 0
      });
    }

    const [libroResult] = await connection.query(
      `
      INSERT INTO libro_cv (
        company_id,
        periodo,
        tipo_libro,
        archivo_nombre
      )
      VALUES (?, ?, ?, ?)
      `,
      [
        Number(company_id),
        periodo,
        tipoLibroDb,
        fileName || ''
      ]
    );

    const libroCvId = libroResult.insertId;

    let importedRows = 0;
    let errorRows = 0;
    const errors = [];

    for (let index = 0; index < rows.length; index++) {
      try {
        const row = rows[index];
        const detalle = mapDetalleRow(row);

        if (!detalle.tipo_documento) {
          errorRows++;
          errors.push({
            row: index + 1,
            message: 'Fila sin tipo de documento'
          });
          continue;
        }

        if (
          detalle.total_documentos < 0 ||
          detalle.monto_exento < 0 ||
          detalle.monto_neto < 0 ||
          detalle.iva_recuperable < 0 ||
          detalle.iva_uso_comun < 0 ||
          detalle.iva_no_recuperable < 0 ||
          detalle.monto_iva < 0 ||
          detalle.monto_total < 0
        ) {
          errorRows++;
          errors.push({
            row: index + 1,
            tipo_documento: detalle.tipo_documento,
            message: 'Fila con montos negativos'
          });
          continue;
        }

        await connection.query(
          `
          INSERT INTO libro_cv_detalle (
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
          )
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          `,
          [
            libroCvId,
            detalle.tipo_documento,
            detalle.total_documentos,
            detalle.monto_exento,
            detalle.monto_neto,
            detalle.iva_recuperable,
            detalle.iva_uso_comun,
            detalle.iva_no_recuperable,
            detalle.monto_iva,
            detalle.monto_total
          ]
        );

        importedRows++;
      } catch (rowError) {
        errorRows++;

        errors.push({
          row: index + 1,
          message: 'Error al insertar fila'
        });

        console.error('SII IMPORT ROW ERROR:', rowError);
      }
    }

    await connection.commit();

    return res.json({
      message: 'Libro importado correctamente al ERP',
      libroCvId,
      company_id: Number(company_id),
      periodo,
      bookType,
      tipoLibroDb,
      fileName,
      totalRows: Number(totalRows || rows.length),
      importedRows,
      duplicatedRows: 0,
      errorRows,
      errors
    });
  } catch (error) {
    await connection.rollback();

    console.error('SII IMPORT ERROR:', error);

    return res.status(500).json({
      message: 'Error al importar libro SII'
    });
  } finally {
    connection.release();
  }
});

module.exports = router;