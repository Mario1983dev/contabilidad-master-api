-- 03_seed_office.sql
-- Inserta una oficina de prueba

USE contabilidad_master;

INSERT INTO offices (rut, name, legal_name, email, phone, status)
VALUES (
  '76123456-7',
  'Oficina Demo',
  'Oficina Demo SpA',
  'contacto@demo.cl',
  '+56911112222',
  1
);

SELECT * FROM offices;