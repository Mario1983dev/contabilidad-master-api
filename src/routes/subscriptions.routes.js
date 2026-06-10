const express = require('express');

function subscriptionsRoutes(pool) {
  const router = express.Router();

  function normalizeDate(value) {
    if (!value) {
      return null;
    }

    return String(value).substring(0, 10);
  }

  router.get('/', async (req, res) => {
    try {
      const [rows] = await pool.query(
        `SELECT
            o.id,
            o.name,
            o.email,
            o.phone,
            o.status,
            o.plan_id,
            p.name AS plan_name,
            p.max_companies,
            p.max_users,
            p.monthly_price,
            o.subscription_status,
            o.subscription_start,
            o.subscription_end,
            o.is_suspended
         FROM offices o
         LEFT JOIN plans p ON p.id = o.plan_id
         ORDER BY o.id DESC`
      );

      return res.json(rows);
    } catch (err) {
      console.error('GET SUBSCRIPTIONS ERROR:', err);
      return res.status(500).json({
        message: 'Error al obtener suscripciones'
      });
    }
  });

  router.get('/plans', async (req, res) => {
    try {
      const [rows] = await pool.query(
        `SELECT id, name, max_companies, max_users, monthly_price, is_active
         FROM plans
         WHERE is_active = 1
         ORDER BY monthly_price ASC, id ASC`
      );

      return res.json(rows);
    } catch (err) {
      console.error('GET PLANS ERROR:', err);
      return res.status(500).json({
        message: 'Error al obtener planes'
      });
    }
  });

  router.put('/:officeId', async (req, res) => {
    try {
      const officeId = Number(req.params.officeId);

      const {
        plan_id,
        subscription_status,
        subscription_start,
        subscription_end,
        is_suspended
      } = req.body || {};

      if (!officeId) {
        return res.status(400).json({
          message: 'Oficina inválida'
        });
      }

      await pool.query(
        `UPDATE offices
         SET
            plan_id = ?,
            subscription_status = ?,
            subscription_start = ?,
            subscription_end = ?,
            is_suspended = ?
         WHERE id = ?`,
        [
          plan_id || null,
          subscription_status || 'ACTIVE',
          normalizeDate(subscription_start),
          normalizeDate(subscription_end),
          Number(is_suspended) === 1 ? 1 : 0,
          officeId
        ]
      );

      return res.json({
        message: 'Suscripción actualizada correctamente'
      });
    } catch (err) {
      console.error('UPDATE SUBSCRIPTION ERROR:', err);
      return res.status(500).json({
        message: 'Error al actualizar suscripción',
        detail: err.message
      });
    }
  });

  return router;
}

module.exports = subscriptionsRoutes;