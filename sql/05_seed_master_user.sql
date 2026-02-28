
-- =============================================
-- SoluSoft - Seed Master User
-- Database: contabilidad_master
-- =============================================

USE contabilidad_master;

INSERT INTO master_users (email, password_hash, is_active)
VALUES (
  'master@solusoft.cl',
  '$2b$10$khqisgGaqObeuyosqPcIOXLxtjj2tBeQSVOk0FeYKwzJi4jTpoYi',
  TRUE
);

-- Verify
SELECT id, email, is_active, created_at
FROM master_users
WHERE email = 'master@solusoft.cl';
