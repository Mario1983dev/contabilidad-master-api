USE contabilidad_master;

/* ======================================================
   12_create_company_accounts.sql
====================================================== */

CREATE TABLE IF NOT EXISTS company_accounts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_id INT NOT NULL,
  code VARCHAR(20) NOT NULL,
  name VARCHAR(150) NOT NULL,
  account_type ENUM('ACTIVO','PASIVO','PATRIMONIO','INGRESO','GASTO','RESULTADO') NOT NULL,
  balance_nature ENUM('DEBITO','CREDITO') NOT NULL,
  parent_code VARCHAR(20) NULL,
  level_num INT NOT NULL DEFAULT 1,
  allows_entries TINYINT(1) NOT NULL DEFAULT 1,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  sort_order INT NOT NULL DEFAULT 0,
  notes VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_company_accounts_company
    FOREIGN KEY (company_id) REFERENCES companies(id),

  CONSTRAINT uq_company_accounts_company_code
    UNIQUE (company_id, code)
);