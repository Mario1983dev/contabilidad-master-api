/* ======================================================
   16_create_journal_entries.sql
   TABLAS DE ASIENTOS CONTABLES
====================================================== */

-- ============================================
-- TABLA: journal_entries (ENCABEZADO)
-- ============================================
CREATE TABLE IF NOT EXISTS journal_entries (
  id INT AUTO_INCREMENT PRIMARY KEY,

  company_id INT NOT NULL,

  entry_date DATE NOT NULL,
  entry_type VARCHAR(50) NOT NULL, -- DIARIO / INGRESO / EGRESO
  description VARCHAR(255),

  status VARCHAR(20) DEFAULT 'posted', -- draft | posted

  created_by INT NULL,

  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_journal_entries_company
    FOREIGN KEY (company_id)
    REFERENCES companies(id)
    ON DELETE CASCADE
);

-- ============================================
-- TABLA: journal_entry_lines (DETALLE)
-- ============================================
CREATE TABLE IF NOT EXISTS journal_entry_lines (
  id INT AUTO_INCREMENT PRIMARY KEY,

  entry_id INT NOT NULL,
  account_id INT NOT NULL,

  description VARCHAR(255),

  debit DECIMAL(15,2) DEFAULT 0,
  credit DECIMAL(15,2) DEFAULT 0,

  CONSTRAINT fk_journal_entry_lines_entry
    FOREIGN KEY (entry_id)
    REFERENCES journal_entries(id)
    ON DELETE CASCADE,

  CONSTRAINT fk_journal_entry_lines_account
    FOREIGN KEY (account_id)
    REFERENCES company_accounts(id)
);

-- ============================================
-- ÍNDICES (RENDIMIENTO 🔥)
-- ============================================
CREATE INDEX idx_journal_entries_company
  ON journal_entries(company_id);

CREATE INDEX idx_journal_entry_lines_entry
  ON journal_entry_lines(entry_id);

CREATE INDEX idx_journal_entry_lines_account
  ON journal_entry_lines(account_id);