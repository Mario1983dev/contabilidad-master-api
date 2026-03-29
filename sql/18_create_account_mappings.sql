CREATE TABLE IF NOT EXISTS account_mappings (
  id INT AUTO_INCREMENT PRIMARY KEY,
  company_id INT NOT NULL,
  mapping_key VARCHAR(50) NOT NULL,
  account_id INT NOT NULL,
  notes VARCHAR(255) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  UNIQUE KEY uq_account_mappings_company_key (company_id, mapping_key),

  CONSTRAINT fk_account_mappings_company
    FOREIGN KEY (company_id) REFERENCES companies(id)
    ON DELETE CASCADE,

  CONSTRAINT fk_account_mappings_account
  FOREIGN KEY (account_id) REFERENCES company_accounts(id)
    ON DELETE RESTRICT
);
