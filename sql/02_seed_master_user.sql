
-- =============================================
-- SoluSoft - Seed Master User
-- Database: contabilidad_master
-- =============================================

USE contabilidad_master;

INSERT IGNORE INTO master_users (email, password_hash, is_active)
VALUES (
  'master@solusoft.cl',
  '$2b$10$8j3RMdRFEk6usKtzS08s9OI.6.DoaHBcLhRzsqmMAFg8be.ScI9Aa',
  TRUE
);

-- Verify
SELECT id, email, is_active, created_at
FROM master_users
WHERE email = 'master@solusoft.cl';
