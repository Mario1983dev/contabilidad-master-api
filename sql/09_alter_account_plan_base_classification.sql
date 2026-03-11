USE contabilidad_master;

/* ======================================================
   09_alter_account_plan_base_classification.sql
   Agrega clasificacion contable al plan base existente
====================================================== */

/* ======================================================
   1) AGREGAR COLUMNAS
====================================================== */
ALTER TABLE account_plan_base
  ADD COLUMN account_type ENUM('ACTIVO','PASIVO','PATRIMONIO','INGRESO','GASTO','RESULTADO')
    NOT NULL DEFAULT 'ACTIVO' AFTER name,
  ADD COLUMN balance_nature ENUM('DEBITO','CREDITO')
    NOT NULL DEFAULT 'DEBITO' AFTER account_type;

/* ======================================================
   2) CLASIFICAR ACTIVO
====================================================== */
UPDATE account_plan_base
SET
  account_type = 'ACTIVO',
  balance_nature = 'DEBITO'
WHERE code IN (
  '1010101', -- CAJA
  '1010120', -- BANCO ESTADO
  '1010130', -- BANCO CHILE
  '1010201', -- CLIENTES
  '1010802', -- IVA CREDITO FISCAL
  '1010630', -- MERCADERIA
  '101001'   -- PPM
);

/* ======================================================
   3) CLASIFICAR PASIVO
====================================================== */
UPDATE account_plan_base
SET
  account_type = 'PASIVO',
  balance_nature = 'CREDITO'
WHERE code IN (
  '2010210', -- CUENTAS POR PAGAR
  '2010120', -- VARIOS ACREEDORES
  '2010925'  -- IVA DEBITO FISCAL
);

/* ======================================================
   4) CLASIFICAR PATRIMONIO
====================================================== */
UPDATE account_plan_base
SET
  account_type = 'PATRIMONIO',
  balance_nature = 'CREDITO'
WHERE code IN (
  '301002', -- CAPITAL PREFERENTE
  '30101'   -- CAPITAL SOCIAL
);

/* ======================================================
   5) CLASIFICAR INGRESOS
====================================================== */
UPDATE account_plan_base
SET
  account_type = 'INGRESO',
  balance_nature = 'CREDITO'
WHERE code IN (
  '4010110', -- VENTAS
  '4010120', -- VENTAS EXENTAS
  '4010601'  -- OTROS INGRESOS
);

/* ======================================================
   6) CLASIFICAR GASTOS
====================================================== */
UPDATE account_plan_base
SET
  account_type = 'GASTO',
  balance_nature = 'DEBITO'
WHERE code IN (
  '4010890', -- GASTOS GENERALES
  '4012210', -- CORRECCION MONETARIA
  '4010701'  -- PERDIDA TRIBUTARIA
);

/* ======================================================
   7) CLASIFICAR RESULTADO
====================================================== */
UPDATE account_plan_base
SET
  account_type = 'RESULTADO',
  balance_nature = 'CREDITO'
WHERE code = '30203'; -- PERDIDA Y GANANCIA

/* ======================================================
   8) VERIFICACION FINAL
====================================================== */
SELECT
  id,
  code,
  name,
  account_type,
  balance_nature,
  parent_code,
  level_num,
  allows_entries,
  is_active,
  sort_order
FROM account_plan_base
ORDER BY sort_order, code;