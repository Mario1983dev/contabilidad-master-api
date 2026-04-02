USE contabilidad_master;

/* ======================================================
   13_create_indexes.sql
   Version compatible con MySQL Workbench / MySQL 8
====================================================== */

/* ======================================================
   companies
====================================================== */

SET @sql = (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.statistics
      WHERE table_schema = 'contabilidad_master'
        AND table_name = 'companies'
        AND index_name = 'idx_companies_office_id'
    ),
    'SELECT ''idx_companies_office_id ya existe'';',
    'CREATE INDEX idx_companies_office_id ON companies(office_id);'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.statistics
      WHERE table_schema = 'contabilidad_master'
        AND table_name = 'companies'
        AND index_name = 'idx_companies_status'
    ),
    'SELECT ''idx_companies_status ya existe'';',
    'CREATE INDEX idx_companies_status ON companies(status);'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

/* ======================================================
   accounting_periods
====================================================== */

SET @sql = (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.statistics
      WHERE table_schema = 'contabilidad_master'
        AND table_name = 'accounting_periods'
        AND index_name = 'idx_accounting_periods_company_id'
    ),
    'SELECT ''idx_accounting_periods_company_id ya existe'';',
    'CREATE INDEX idx_accounting_periods_company_id ON accounting_periods(company_id);'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.statistics
      WHERE table_schema = 'contabilidad_master'
        AND table_name = 'accounting_periods'
        AND index_name = 'idx_accounting_periods_status'
    ),
    'SELECT ''idx_accounting_periods_status ya existe'';',
    'CREATE INDEX idx_accounting_periods_status ON accounting_periods(status);'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

/* ======================================================
   company_accounts
====================================================== */

SET @sql = (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.statistics
      WHERE table_schema = 'contabilidad_master'
        AND table_name = 'company_accounts'
        AND index_name = 'idx_company_accounts_company_id'
    ),
    'SELECT ''idx_company_accounts_company_id ya existe'';',
    'CREATE INDEX idx_company_accounts_company_id ON company_accounts(company_id);'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

SET @sql = (
  SELECT IF(
    EXISTS (
      SELECT 1
      FROM information_schema.statistics
      WHERE table_schema = 'contabilidad_master'
        AND table_name = 'company_accounts'
        AND index_name = 'idx_company_accounts_active'
    ),
    'SELECT ''idx_company_accounts_active ya existe'';',
    'CREATE INDEX idx_company_accounts_active ON company_accounts(is_active);'
  )
);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;