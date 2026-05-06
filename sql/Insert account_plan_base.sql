-- ============================================
-- SEED: account_plan_base
-- ============================================

USE contabilidad_master;

INSERT INTO account_plan_base (code, name, account_type, balance_nature, parent_code, level_num, allows_entries, is_active, sort_order, notes, created_at, updated_at) VALUES ('1010101', 'CAJA', 'ACTIVO', 'DEBITO', NULL, 1, 1, 1, 10, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-08 15:50:25');
INSERT INTO account_plan_base VALUES ('4010110', 'VENTAS', 'INGRESO', 'CREDITO', NULL, 1, 1, 1, 20, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-11 13:23:53');
INSERT INTO account_plan_base VALUES ('4010120', 'VENTAS EXENTAS', 'INGRESO', 'CREDITO', NULL, 1, 1, 1, 30, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-11 13:23:53');
INSERT INTO account_plan_base VALUES ('2010925', 'IVA DEBITO FISCAL', 'PASIVO', 'CREDITO', NULL, 1, 1, 1, 40, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-11 13:23:53');
INSERT INTO account_plan_base VALUES ('1010802', 'IVA CREDITO FISCAL', 'ACTIVO', 'DEBITO', NULL, 1, 1, 1, 50, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-08 15:50:25');
INSERT INTO account_plan_base VALUES ('1010630', 'MERCADERIA', 'ACTIVO', 'DEBITO', NULL, 1, 1, 1, 60, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-08 15:50:25');
INSERT INTO account_plan_base VALUES ('1010801', 'PPM', 'ACTIVO', 'DEBITO', NULL, 1, 1, 1, 70, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-08 15:50:25');
INSERT INTO account_plan_base VALUES ('30102', 'CAPITAL PREFERENTE', 'ACTIVO', 'DEBITO', NULL, 1, 1, 1, 80, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-08 15:50:25');
INSERT INTO account_plan_base VALUES ('30101', 'CAPITAL SOCIAL', 'PATRIMONIO', 'CREDITO', NULL, 1, 1, 1, 90, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-11 13:23:53');
INSERT INTO account_plan_base VALUES ('2010210', 'CUENTAS POR PAGAR', 'PASIVO', 'CREDITO', NULL, 1, 1, 1, 100, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-11 13:23:53');
INSERT INTO account_plan_base VALUES ('2010120', 'VARIOS ACREEDORES', 'PASIVO', 'CREDITO', NULL, 1, 1, 1, 110, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-11 13:23:53');
INSERT INTO account_plan_base VALUES ('4010601', 'OTROS INGRESOS', 'INGRESO', 'CREDITO', NULL, 1, 1, 1, 120, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-11 13:23:53');
INSERT INTO account_plan_base VALUES ('4010890', 'GASTOS GENERALES', 'GASTO', 'DEBITO', NULL, 1, 1, 1, 130, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-11 13:23:53');
INSERT INTO account_plan_base VALUES ('4012210', 'CORRECCION MONETARIA', 'GASTO', 'DEBITO', NULL, 1, 1, 1, 140, 'En hoja aparece como C Monetaria', '2026-03-08 15:50:25', '2026-03-11 13:23:53');
INSERT INTO account_plan_base VALUES ('30203', 'PERDIDA Y GANANCIA', 'RESULTADO', 'CREDITO', NULL, 1, 1, 1, 150, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-11 13:23:53');
INSERT INTO account_plan_base VALUES ('4010701', 'PERDIDA TRIBUTARIA', 'GASTO', 'DEBITO', NULL, 1, 1, 1, 160, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-11 13:23:53');
INSERT INTO account_plan_base VALUES ('1010220', 'RETIROS', 'ACTIVO', 'DEBITO', NULL, 1, 1, 1, 170, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-08 15:50:25');
INSERT INTO account_plan_base VALUES ('4010220', 'COSTO DE VENTA', 'ACTIVO', 'DEBITO', NULL, 1, 1, 1, 180, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-08 15:50:25');
INSERT INTO account_plan_base VALUES ('4010815', 'ARRIENDOS', 'ACTIVO', 'DEBITO', NULL, 1, 1, 1, 190, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-08 15:50:25');
INSERT INTO account_plan_base VALUES ('4010810', 'SUELDOS', 'ACTIVO', 'DEBITO', NULL, 1, 1, 1, 200, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-08 15:50:25');
INSERT INTO account_plan_base VALUES ('4010822', 'HONORARIOS', 'ACTIVO', 'DEBITO', NULL, 1, 1, 1, 210, 'Extraido de imagen enviada por usuario', '2026-03-08 15:50:25', '2026-03-08 15:50:25');

INSERT INTO entry_types 
(code, name, description, affects_balance, is_system, created_at)
VALUES
('MANUAL', 'Manual', 'Asiento manual general', 1, 1, NOW()),
('APERTURA', 'Apertura', 'Asiento de apertura de periodo', 1, 1, NOW()),
('AJUSTE', 'Ajuste', 'Ajuste contable', 1, 1, NOW()),
('REAPERTURA', 'Reapertura', 'Reapertura de periodo', 1, 1, NOW());

CREATE INDEX idx_jel_entry_account
ON journal_entry_lines (entry_id, account_id);

CREATE INDEX idx_ca_company
ON company_accounts (company_id);