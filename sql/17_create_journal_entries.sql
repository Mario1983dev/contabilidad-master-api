/* ======================================================
   TABLA: journal_entries
====================================================== */
CREATE TABLE IF NOT EXISTS journal_entries (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_id INT NOT NULL,
  entry_date DATE NOT NULL,
  entry_type VARCHAR(20) DEFAULT 'MANUAL',
  description VARCHAR(255) NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_company_id (company_id)
);


/* ======================================================
   TABLA: journal_entry_lines
====================================================== */
CREATE TABLE IF NOT EXISTS journal_entry_lines (
  id INT AUTO_INCREMENT PRIMARY KEY,
  journal_entry_id INT NOT NULL,
  account_code VARCHAR(20) NOT NULL,
  debit DECIMAL(12,2) DEFAULT 0,
  credit DECIMAL(12,2) DEFAULT 0,

  INDEX idx_entry_id (journal_entry_id),
  INDEX idx_account_code (account_code),

  CONSTRAINT fk_entry_lines
    FOREIGN KEY (journal_entry_id)
    REFERENCES journal_entries(id)
    ON DELETE CASCADE
);