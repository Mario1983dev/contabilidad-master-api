const jwt = require('jsonwebtoken');

function authenticateToken(req, res, next) {
  try {
    const authHeader = req.headers.authorization || '';
    const token = authHeader.startsWith('Bearer ')
      ? authHeader.slice(7).trim()
      : null;

    if (!token) {
      return res.status(401).json({ message: 'Token requerido' });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    req.user = {
      id: decoded.id,
      username: decoded.username,
      email: decoded.email,
      role: decoded.role,
      scope: decoded.scope,
      office_id: decoded.office_id
    };

    next();
  } catch (error) {
    return res.status(401).json({ message: 'Token inválido o expirado' });
  }
}

function allowRoles(...allowedRoles) {
  return (req, res, next) => {
    const userRole = String(req.user?.role || '').trim().toUpperCase();

    if (!userRole) {
      return res.status(403).json({ message: 'Usuario sin rol válido' });
    }

    const normalizedAllowed = allowedRoles.map(r =>
      String(r).trim().toUpperCase()
    );

    if (!normalizedAllowed.includes(userRole)) {
      return res.status(403).json({ message: 'Sin permisos' });
    }

    next();
  };
}

module.exports = {
  authenticateToken,
  allowRoles
};