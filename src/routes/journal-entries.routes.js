const express = require('express');
const {
  authenticateToken,
  allowRoles
} = require('../middlewares/auth.middleware');

module.exports = (pool) => {
  const router = express.Router();

  router.get(
    '/',
    authenticateToken,
    allowRoles('MASTER', 'OFFICE_ADMIN', 'OFFICE_USER'),
    async (req, res) => {
      res.json({ ok: true });
    }
  );

  return router;
};