const express = require('express');

module.exports = (pool, authenticateToken, allowRoles) => {
  const router = express.Router();

  function safeName(value, fallback) {
    const text = String(value || fallback || 'export').trim();
    return text
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')
      .replace(/[^a-zA-Z0-9_-]+/g, '_')
      .replace(/^_+|_+$/g, '')
      .slice(0, 80) || fallback || 'export';
  }

  async function safeQuery(sql, params = []) {
    try {
      const [rows] = await pool.query(sql, params);
      return rows || [];
    } catch (err) {
      // Permite que la exportación siga si una tabla opcional aún no existe.
      return {
        warning: 'No fue posible exportar esta sección',
        detail: err?.message || String(err)
      };
    }
  }

  async function logAudit(req, action, entity, entityId, description) {
    try {
      await pool.query(
        `INSERT INTO audit_log (actor_type, actor_id, action, entity, entity_id, created_at)
         VALUES (?, ?, ?, ?, ?, NOW())`,
        [
          'USER',
          req.user?.id || null,
          action,
          entity,
          entityId || null
        ]
      );
    } catch (err) {
      console.warn('AUDIT EXPORT WARNING:', err?.message || err);
    }
  }

  function canAccessOffice(req, officeId) {
    const role = String(req.user?.role || '').trim().toUpperCase();
    if (role === 'MASTER') return true;
    return Number(req.user?.office_id) === Number(officeId);
  }

  function sendJsonDownload(res, filename, payload) {
    const body = JSON.stringify(payload, null, 2);
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    res.setHeader('Content-Disposition', `attachment; filename="${filename}"`);
    return res.send(body);
  }

  async function buildCompanyExport(companyId) {
    const companyRows = await safeQuery(
      `SELECT c.*, o.name AS office_name
       FROM companies c
       LEFT JOIN offices o ON o.id = c.office_id
       WHERE c.id = ?
       LIMIT 1`,
      [companyId]
    );

    if (!Array.isArray(companyRows) || companyRows.length === 0) {
      return null;
    }

    const company = companyRows[0];

    const periods = await safeQuery(
      `SELECT * FROM accounting_periods WHERE company_id = ? ORDER BY year_num DESC, id DESC`,
      [companyId]
    );

    const accounts = await safeQuery(
      `SELECT * FROM company_accounts WHERE company_id = ? ORDER BY sort_order, code`,
      [companyId]
    );

    const journalEntries = await safeQuery(
      `SELECT * FROM journal_entries WHERE company_id = ? ORDER BY entry_date, id`,
      [companyId]
    );

    const journalEntryLines = await safeQuery(
      `SELECT jel.*
       FROM journal_entry_lines jel
       INNER JOIN journal_entries je ON je.id = jel.entry_id
       WHERE je.company_id = ?
       ORDER BY jel.entry_id, jel.id`,
      [companyId]
    );

    const libroCv = await safeQuery(
      `SELECT * FROM libro_cv WHERE company_id = ? ORDER BY periodo DESC, id DESC`,
      [companyId]
    );

    let libroCvDetalle = [];
    if (Array.isArray(libroCv) && libroCv.length > 0) {
      const ids = libroCv.map((r) => Number(r.id)).filter(Boolean);
      if (ids.length > 0) {
        const placeholders = ids.map(() => '?').join(',');
        libroCvDetalle = await safeQuery(
          `SELECT * FROM libro_cv_detalle WHERE libro_cv_id IN (${placeholders}) ORDER BY libro_cv_id, id`,
          ids
        );
      }
    }

    return {
      metadata: {
        export_type: 'COMPANY_DATA_EXPORT',
        generated_at: new Date().toISOString(),
        company_id: Number(companyId),
        office_id: company.office_id || null,
        note: 'Exportación lógica de datos. No incluye PDFs generados al vuelo.'
      },
      company,
      accounting_periods: periods,
      company_accounts: accounts,
      journal_entries: journalEntries,
      journal_entry_lines: journalEntryLines,
      libro_cv: libroCv,
      libro_cv_detalle: libroCvDetalle
    };
  }

  router.get(
    '/company/:companyId',
    authenticateToken,
    allowRoles('MASTER', 'OFFICE_ADMIN', 'OFFICE_USER'),
    async (req, res) => {
      try {
        const companyId = Number(req.params.companyId);
        if (!companyId || Number.isNaN(companyId)) {
          return res.status(400).json({ message: 'ID de empresa inválido' });
        }

        const payload = await buildCompanyExport(companyId);
        if (!payload) {
          return res.status(404).json({ message: 'Empresa no encontrada' });
        }

        if (!canAccessOffice(req, payload.company.office_id)) {
          return res.status(403).json({ message: 'No puedes exportar esta empresa' });
        }

        await logAudit(req, 'EXPORT', 'companies', companyId, 'Exportación de datos por empresa');

        const filename = `empresa_${companyId}_${safeName(payload.company.name, 'empresa')}_${new Date().toISOString().slice(0, 10)}.json`;
        return sendJsonDownload(res, filename, payload);
      } catch (err) {
        console.error('EXPORT COMPANY ERROR:', err);
        return res.status(500).json({ message: 'Error interno al exportar empresa' });
      }
    }
  );

  router.get(
    '/office/:officeId',
    authenticateToken,
    allowRoles('MASTER', 'OFFICE_ADMIN'),
    async (req, res) => {
      try {
        const officeId = Number(req.params.officeId);
        if (!officeId || Number.isNaN(officeId)) {
          return res.status(400).json({ message: 'ID de oficina inválido' });
        }

        if (!canAccessOffice(req, officeId)) {
          return res.status(403).json({ message: 'No puedes exportar esta oficina' });
        }

        const officeRows = await safeQuery(`SELECT * FROM offices WHERE id = ? LIMIT 1`, [officeId]);
        if (!Array.isArray(officeRows) || officeRows.length === 0) {
          return res.status(404).json({ message: 'Oficina no encontrada' });
        }

        const companies = await safeQuery(
          `SELECT * FROM companies WHERE office_id = ? ORDER BY id`,
          [officeId]
        );

        const users = await safeQuery(
          `SELECT id, office_id, username, name, email, role, status, created_at, updated_at
           FROM office_users
           WHERE office_id = ?
           ORDER BY id`,
          [officeId]
        );

        const companyExports = [];
        if (Array.isArray(companies)) {
          for (const company of companies) {
            const companyPayload = await buildCompanyExport(company.id);
            if (companyPayload) companyExports.push(companyPayload);
          }
        }

        const payload = {
          metadata: {
            export_type: 'OFFICE_DATA_EXPORT',
            generated_at: new Date().toISOString(),
            office_id: officeId,
            note: 'Exportación lógica de datos por oficina. No incluye PDFs generados al vuelo ni contraseñas.'
          },
          office: officeRows[0],
          office_users: users,
          companies,
          company_exports: companyExports
        };

        await logAudit(req, 'EXPORT', 'offices', officeId, 'Exportación de datos por oficina');

        const filename = `oficina_${officeId}_${safeName(officeRows[0].name, 'oficina')}_${new Date().toISOString().slice(0, 10)}.json`;
        return sendJsonDownload(res, filename, payload);
      } catch (err) {
        console.error('EXPORT OFFICE ERROR:', err);
        return res.status(500).json({ message: 'Error interno al exportar oficina' });
      }
    }
  );

  return router;
};
