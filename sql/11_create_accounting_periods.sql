USE contabilidad_master;

/* ======================================================
   11_create_accounting_periods.sql
====================================================== */

CREATE TABLE IF NOT EXISTS accounting_periods (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_id INT NOT NULL,
  year_num INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status ENUM('OPEN','CLOSED') NOT NULL DEFAULT 'OPEN',
  is_current TINYINT(1) NOT NULL DEFAULT 1,
  notes VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_accounting_periods_company
    FOREIGN KEY (company_id) REFERENCES companies(id),

  CONSTRAINT uq_accounting_periods_company_year
    UNIQUE (company_id, year_num)
);