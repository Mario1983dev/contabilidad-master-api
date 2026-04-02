USE contabilidad_master;

/* ======================================================
   09_alter_account_plan_base_classification.sql
   Clasificación contable del plan base
====================================================== */

/* ======================================================
   0) CREAR TABLA SI NO EXISTE
====================================================== */
CREATE TABLE IF NOT EXISTS account_plan_base (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(20) NOT NULL,
  name VARCHAR(150) NOT NULL,
  parent_code VARCHAR(20) NULL,
  level_num INT NOT NULL DEFAULT 1,
  allows_entries TINYINT(1) NOT NULL DEFAULT 1,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_account_plan_base_code (code)
);

/* ======================================================
   1) AGREGAR account_type SI NO EXISTE
====================================================== */
SET @sql = (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = 'contabilidad_master'
        AND TABLE_NAME = 'account_plan_base'
        AND COLUMN_NAME = 'account_type'
    ),
    'SELECT ''account_type ya existe'';',
    'ALTER TABLE account_plan_base
       ADD COLUMN account_type ENUM(''ACTIVO'',''PASIVO'',''PATRIMONIO'',''INGRESO'',''GASTO'',''RESULTADO'')
       NOT NULL DEFAULT ''ACTIVO'' AFTER name;'
  )
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

/* ======================================================
   2) AGREGAR balance_nature SI NO EXISTE
====================================================== */
SET @sql = (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.COLUMNS
      WHERE TABLE_SCHEMA = 'contabilidad_master'
        AND TABLE_NAME = 'account_plan_base'
        AND COLUMN_NAME = 'balance_nature'
    ),
    'SELECT ''balance_nature ya existe'';',
    'ALTER TABLE account_plan_base
       ADD COLUMN balance_nature ENUM(''DEBITO'',''CREDITO'')
       NOT NULL DEFAULT ''DEBITO'' AFTER account_type;'
  )
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

/* ======================================================
   3) CLASIFICAR ACTIVO
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
   4) CLASIFICAR PASIVO
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
   5) CLASIFICAR PATRIMONIO
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
   6) CLASIFICAR INGRESOS
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
   7) CLASIFICAR GASTOS
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
   8) CLASIFICAR RESULTADO
====================================================== */
UPDATE account_plan_base
SET
  account_type = 'RESULTADO',
  balance_nature = 'CREDITO'
WHERE code = '30203'; -- PERDIDA Y GANANCIA

/* ======================================================
   9) VERIFICACION FINAL
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