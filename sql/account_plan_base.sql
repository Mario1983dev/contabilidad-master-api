-- =========================================================
-- SoluSoft SPA - Plan de cuentas base
-- Generado a partir de la imagen enviada por el usuario
-- Fecha: 2026-03-08
-- =========================================================

CREATE DATABASE IF NOT EXISTS contabilidad_master;
USE contabilidad_master;

-- =========================================================
-- TABLA BASE INDEPENDIENTE DEL PLAN DE CUENTAS
-- =========================================================
CREATE TABLE IF NOT EXISTS account_plan_base (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL,
  name VARCHAR(150) NOT NULL,
  parent_code VARCHAR(20) NULL,
  level_num INT NOT NULL DEFAULT 1,
  allows_entries TINYINT(1) NOT NULL DEFAULT 1,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  sort_order INT NOT NULL DEFAULT 0,
  notes VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_account_plan_base_code (code)
);

-- =========================================================
-- LIMPIEZA OPCIONAL ANTES DE CARGAR
-- =========================================================
-- DELETE FROM account_plan_base;

-- =========================================================
-- CARGA INICIAL
-- NOTA:
-- 1) Se cargan las cuentas que se leen con claridad en la hoja.
-- 2) parent_code y level_num quedan neutrales por ahora.
-- 3) Las anotaciones manuscritas al pie de la hoja NO se cargan
--    automáticamente porque no se distinguen con suficiente certeza.
-- =========================================================
INSERT INTO account_plan_base
(code, name, parent_code, level_num, allows_entries, is_active, sort_order, notes)
VALUES
('1010101', 'CAJA', NULL, 1, 1, 1, 10, 'Extraido de imagen enviada por usuario'),
('4010110', 'VENTAS', NULL, 1, 1, 1, 20, 'Extraido de imagen enviada por usuario'),
('4010120', 'VENTAS EXENTAS', NULL, 1, 1, 1, 30, 'Extraido de imagen enviada por usuario'),
('2010925', 'IVA DEBITO FISCAL', NULL, 1, 1, 1, 40, 'Extraido de imagen enviada por usuario'),
('1010802', 'IVA CREDITO FISCAL', NULL, 1, 1, 1, 50, 'Extraido de imagen enviada por usuario'),
('1010630', 'MERCADERIA', NULL, 1, 1, 1, 60, 'Extraido de imagen enviada por usuario'),
('1010801', 'PPM', NULL, 1, 1, 1, 70, 'Extraido de imagen enviada por usuario'),
('30102', 'CAPITAL PREFERENTE', NULL, 1, 1, 1, 80, 'Extraido de imagen enviada por usuario'),
('30101', 'CAPITAL SOCIAL', NULL, 1, 1, 1, 90, 'Extraido de imagen enviada por usuario'),
('2010210', 'CUENTAS POR PAGAR', NULL, 1, 1, 1, 100, 'Extraido de imagen enviada por usuario'),
('2010120', 'VARIOS ACREEDORES', NULL, 1, 1, 1, 110, 'Extraido de imagen enviada por usuario'),
('4010601', 'OTROS INGRESOS', NULL, 1, 1, 1, 120, 'Extraido de imagen enviada por usuario'),
('4010890', 'GASTOS GENERALES', NULL, 1, 1, 1, 130, 'Extraido de imagen enviada por usuario'),
('4012210', 'CORRECCION MONETARIA', NULL, 1, 1, 1, 140, 'En hoja aparece como C Monetaria'),
('30203', 'PERDIDA Y GANANCIA', NULL, 1, 1, 1, 150, 'Extraido de imagen enviada por usuario'),
('4010701', 'PERDIDA TRIBUTARIA', NULL, 1, 1, 1, 160, 'Extraido de imagen enviada por usuario'),
('1010220', 'RETIROS', NULL, 1, 1, 1, 170, 'Extraido de imagen enviada por usuario'),
('4010220', 'COSTO DE VENTA', NULL, 1, 1, 1, 180, 'Extraido de imagen enviada por usuario'),
('4010815', 'ARRIENDOS', NULL, 1, 1, 1, 190, 'Extraido de imagen enviada por usuario'),
('4010810', 'SUELDOS', NULL, 1, 1, 1, 200, 'Extraido de imagen enviada por usuario'),
('4010822', 'HONORARIOS', NULL, 1, 1, 1, 210, 'Extraido de imagen enviada por usuario'),
('2010930', 'RTA 2DA CATG', NULL, 1, 1, 1, 220, 'Descripcion tal como aparece en hoja'),
('2010910', 'IMPUESTO UNICO', NULL, 1, 1, 1, 230, 'Extraido de imagen enviada por usuario'),
('30202', 'UTILIDADES POR CAPITALIZAR', NULL, 1, 1, 1, 240, 'Extraido de imagen enviada por usuario'),
('1020820', 'MUEBLES Y UTILES', NULL, 1, 1, 1, 250, 'Extraido de imagen enviada por usuario'),
('30601', 'FDO. REV. CAP. PROPIO', NULL, 1, 1, 1, 260, 'Extraido de imagen enviada por usuario'),
('2020101', 'DEPRE. ACUMULADA', NULL, 1, 1, 1, 270, 'Extraido de imagen enviada por usuario'),
('1010353', 'VEHICULO', NULL, 1, 1, 1, 280, 'Extraido de imagen enviada por usuario'),
('2020601', 'FDO UTILID. ACUMULADAS', NULL, 1, 1, 1, 290, 'Extraido de imagen enviada por usuario'),
('1010310', 'HERRAMIENTAS', NULL, 1, 1, 1, 300, 'Extraido de imagen enviada por usuario'),
('1020810', 'MAQUINARIAS', NULL, 1, 1, 1, 310, 'Extraido de imagen enviada por usuario'),
('1010370', 'PRESTAMO SOLIDARIO', NULL, 1, 1, 1, 320, 'Extraido de imagen enviada por usuario'),
('4012570', 'IMPTO. RTA. PRIMERA CATG.', NULL, 1, 1, 1, 330, 'Extraido de imagen enviada por usuario'),
('30103', 'CTA. CAP. SOCIO 1', NULL, 1, 1, 1, 340, 'Extraido de imagen enviada por usuario'),
('30104', 'CTA. CAP. SOCIO 2', NULL, 1, 1, 1, 350, 'Extraido de imagen enviada por usuario'),
('1020201', 'GARANTIA ARRIENDO', NULL, 1, 1, 1, 360, 'Extraido de imagen enviada por usuario'),
('4010916', 'COMPRA EXENTAS', NULL, 1, 1, 1, 370, 'Descripcion tal como aparece en hoja')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  parent_code = VALUES(parent_code),
  level_num = VALUES(level_num),
  allows_entries = VALUES(allows_entries),
  is_active = VALUES(is_active),
  sort_order = VALUES(sort_order),
  notes = VALUES(notes),
  updated_at = CURRENT_TIMESTAMP;

-- =========================================================
-- CONSULTA DE VERIFICACION
-- =========================================================
SELECT id, code, name, parent_code, level_num, allows_entries, is_active, sort_order
FROM account_plan_base
ORDER BY sort_order, code;

-- =========================================================
-- CUENTAS MANUSCRITAS PENDIENTES DE VALIDAR CON EL USUARIO
-- =========================================================
-- En la foto aparecen anotaciones al pie, pero no se distinguen con total certeza.
-- Posibles codigos vistos:
--   1020824
--   3010130
--   1010320
--   2010215
--   2010228
-- Posibles descripciones vistas:
--   compra(s) exentas
--   sueldo(s) x pagar
--   PPM x pagar
-- Validar estas antes de agregarlas al plan base.
