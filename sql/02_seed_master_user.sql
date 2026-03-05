
-- =============================================
-- SoluSoft - Seed Master User
-- Database: contabilidad_master
-- =============================================

USE contabilidad_master;

INSERT IGNORE INTO master_users (email, password_hash, is_active)
VALUES (
  'master@solusoft.cl',
  '$2b$10$7EqJtq98hPqEX7fNZaFWoOHi3QqSdz8CA0nVddOZXS6jttuPAoBsK',
  TRUE
);

-- Verify
SELECT id, email, is_active, created_at
FROM master_users
WHERE email = 'master@solusoft.cl';
