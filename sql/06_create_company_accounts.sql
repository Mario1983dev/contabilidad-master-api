
-- =====================================================
-- SOLUSOFT ERP
-- Script: 06_create_company_accounts.sql
-- Description: Tabla de plan de cuentas por empresa
-- =====================================================

USE contabilidad_master;

-- =====================================================
-- TABLA: company_accounts
-- Cada empresa tendrá su propio plan de cuentas
-- =====================================================

CREATE TABLE IF NOT EXISTS company_accounts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_id INT NOT NULL,
  code VARCHAR(20) NOT NULL,
  name VARCHAR(150) NOT NULL,
  parent_code VARCHAR(20) NULL,
  level_num INT NOT NULL DEFAULT 1,
  allows_entries TINYINT(1) NOT NULL DEFAULT 1,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  sort_order INT NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  INDEX idx_company_accounts_company (company_id),
  UNIQUE KEY uq_company_accounts_company_code (company_id, code)
);

-- =====================================================
-- EJEMPLO: Copiar plan base a empresa
-- =====================================================
-- Reemplazar el número 1 por el ID real de la empresa

/*
INSERT INTO company_accounts
(company_id, code, name, parent_code, level_num, allows_entries, is_active, sort_order)
SELECT
1,
code,
name,
parent_code,
level_num,
allows_entries,
is_active,
sort_order
FROM account_plan_base;
*/

-- =====================================================
-- VERIFICACION
-- =====================================================
SELECT * FROM company_accounts;
