-- 04_seed_office_admin.sql
-- Inserta un administrador para la oficina 1

USE contabilidad_master;

INSERT INTO office_admins (office_id, email, password_hash)
VALUES (
  1,
  'admin@demo.cl',
  '$2b$10$khqisgGaqObeuyosqPcIOXLxtjj2tBeQSVOk0FeYKwzJi4jTpoYi'
);

SELECT * FROM office_admins;
