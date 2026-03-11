const express = require('express');

module.exports = (pool) => {
  const router = express.Router();

  /* ======================================================
     LISTAR EMPRESAS (TODAS: ACTIVAS E INACTIVAS)
  ====================================================== */
  router.get('/', async (req, res) => {
    try {
      const [rows] = await pool.query(`
        SELECT
          c.id,
          c.office_id,
          c.rut,
          c.name,
          c.legal_name,
          c.business_type,
          c.email,
          c.phone,
          c.address,
          c.commune,
          c.city,
          c.region_name,
          c.status,
          c.notes,
          p.year_num,
          c.created_at,
          c.updated_at,
          o.name AS office_name
        FROM companies c
        INNER JOIN offices o ON o.id = c.office_id
        LEFT JOIN accounting_periods p
          ON p.company_id = c.id
         AND p.is_current = 1
        ORDER BY c.id DESC
      `);

      res.json(rows);
    } catch (err) {
      console.error('LIST COMPANIES ERROR:', err);
      res.status(500).json({ message: 'Error interno al listar empresas' });
    }
  });

  /* ======================================================
     OBTENER EMPRESA POR ID
  ====================================================== */
  router.get('/:id', async (req, res) => {
    try {
      const { id } = req.params;

      const [rows] = await pool.query(`
        SELECT
          c.id,
          c.office_id,
          c.rut,
          c.name,
          c.legal_name,
          c.business_type,
          c.email,
          c.phone,
          c.address,
          c.commune,
          c.city,
          c.region_name,
          c.status,
          c.notes,
          p.year_num,
          c.created_at,
          c.updated_at
        FROM companies c
        LEFT JOIN accounting_periods p
          ON p.company_id = c.id
         AND p.is_current = 1
        WHERE c.id = ?
      `, [id]);

      if (rows.length === 0) {
        return res.status(404).json({ message: 'Empresa no encontrada' });
      }

      res.json(rows[0]);
    } catch (err) {
      console.error('GET COMPANY ERROR:', err);
      res.status(500).json({ message: 'Error interno al obtener empresa' });
    }
  });

  /* ======================================================
     CREAR EMPRESA
  ====================================================== */
  router.post('/', async (req, res) => {
    const connection = await pool.getConnection();

    try {
      const {
        office_id,
        rut,
        name,
        legal_name,
        business_type,
        email,
        phone,
        address,
        commune,
        city,
        region_name,
        status,
        notes,
        year_num
      } = req.body || {};

      if (!office_id || !rut || !name) {
        return res.status(400).json({
          message: 'office_id, rut y name son obligatorios'
        });
      }

      const accountingYear = Number(year_num) || new Date().getFullYear();
      const start_date = `${accountingYear}-01-01`;
      const end_date = `${accountingYear}-12-31`;

      await connection.beginTransaction();

      const [officeRows] = await connection.query(
        `SELECT id FROM offices WHERE id = ?`,
        [office_id]
      );

      if (officeRows.length === 0) {
        await connection.rollback();
        return res.status(400).json({ message: 'La oficina indicada no existe' });
      }

      const [existingCompany] = await connection.query(
        `SELECT id FROM companies WHERE office_id = ? AND rut = ?`,
        [office_id, rut]
      );

      if (existingCompany.length > 0) {
        await connection.rollback();
        return res.status(400).json({
          message: 'Ya existe una empresa con ese RUT en esta oficina'
        });
      }

      const [companyResult] = await connection.query(`
        INSERT INTO companies (
          office_id,
          rut,
          name,
          legal_name,
          business_type,
          email,
          phone,
          address,
          commune,
          city,
          region_name,
          status,
          notes
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `,
      [
        office_id,
        rut,
        name,
        legal_name || null,
        business_type || null,
        email || null,
        phone || null,
        address || null,
        commune || null,
        city || null,
        region_name || null,
        status || 'active',
        notes || null
      ]);

      const companyId = companyResult.insertId;

      await connection.query(`
        INSERT INTO accounting_periods (
          company_id,
          year_num,
          start_date,
          end_date,
          status,
          is_current,
          notes
        )
        VALUES (?, ?, ?, ?, 'OPEN', 1, ?)
      `,
      [
        companyId,
        accountingYear,
        start_date,
        end_date,
        `Periodo inicial creado automaticamente para la empresa ${name}`
      ]);

      await connection.query(`
        INSERT INTO company_accounts (
          company_id,
          code,
          name,
          account_type,
          balance_nature,
          parent_code,
          level_num,
          allows_entries,
          is_active,
          sort_order,
          notes
        )
        SELECT
          ?,
          apb.code,
          apb.name,
          apb.account_type,
          apb.balance_nature,
          apb.parent_code,
          apb.level_num,
          apb.allows_entries,
          apb.is_active,
          apb.sort_order,
          apb.notes
        FROM account_plan_base apb
        ORDER BY apb.sort_order, apb.code
      `,
      [companyId]);

      await connection.commit();

      res.status(201).json({
        message: 'Empresa creada correctamente',
        company_id: companyId
      });
    } catch (err) {
      await connection.rollback();
      console.error('CREATE COMPANY ERROR:', err);
      res.status(500).json({ message: 'Error interno al crear empresa' });
    } finally {
      connection.release();
    }
  });

  /* ======================================================
     ACTUALIZAR EMPRESA
  ====================================================== */
  router.put('/:id', async (req, res) => {
    const connection = await pool.getConnection();

    try {
      const { id } = req.params;

      const {
        office_id,
        rut,
        name,
        legal_name,
        business_type,
        email,
        phone,
        address,
        commune,
        city,
        region_name,
        status,
        notes,
        year_num
      } = req.body || {};

      if (!rut || !name) {
        return res.status(400).json({
          message: 'rut y name son obligatorios'
        });
      }

      await connection.beginTransaction();

      const [existingRows] = await connection.query(
        `SELECT id FROM companies WHERE id = ?`,
        [id]
      );

      if (existingRows.length === 0) {
        await connection.rollback();
        return res.status(404).json({ message: 'Empresa no encontrada' });
      }

      await connection.query(`
        UPDATE companies
        SET
          office_id = ?,
          rut = ?,
          name = ?,
          legal_name = ?,
          business_type = ?,
          email = ?,
          phone = ?,
          address = ?,
          commune = ?,
          city = ?,
          region_name = ?,
          status = ?,
          notes = ?
        WHERE id = ?
      `,
      [
        office_id || 1,
        rut,
        name,
        legal_name || null,
        business_type || null,
        email || null,
        phone || null,
        address || null,
        commune || null,
        city || null,
        region_name || null,
        status || 'active',
        notes || null,
        id
      ]);

      if (year_num) {
        await connection.query(`
          UPDATE accounting_periods
          SET year_num = ?, start_date = ?, end_date = ?
          WHERE company_id = ? AND is_current = 1
        `,
        [
          Number(year_num),
          `${Number(year_num)}-01-01`,
          `${Number(year_num)}-12-31`,
          id
        ]);
      }

      await connection.commit();

      res.json({ message: 'Empresa actualizada correctamente' });
    } catch (err) {
      await connection.rollback();
      console.error('UPDATE COMPANY ERROR:', err);
      res.status(500).json({ message: 'Error interno al actualizar empresa' });
    } finally {
      connection.release();
    }
  });

  /* ======================================================
     DESACTIVAR EMPRESA (NO ELIMINAR)
  ====================================================== */
  router.delete('/:id', async (req, res) => {
    try {
      const { id } = req.params;

      const [result] = await pool.query(`
        UPDATE companies
        SET status = 'inactive'
        WHERE id = ?
      `, [id]);

      if (result.affectedRows === 0) {
        return res.status(404).json({ message: 'Empresa no encontrada' });
      }

      res.json({ message: 'Empresa desactivada correctamente' });
    } catch (err) {
      console.error('DEACTIVATE COMPANY ERROR:', err);
      res.status(500).json({ message: 'Error interno al desactivar empresa' });
    }
  });

  return router;
};