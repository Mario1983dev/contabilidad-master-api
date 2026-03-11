USE contabilidad_master;

/* ======================================================
   13_create_companies_indexes.sql
====================================================== */

 CREATE INDEX idx_companies_office_id
 ON companies(office_id);

 
 CREATE INDEX idx_companies_status
 ON companies(status);

CREATE INDEX idx_accounting_periods_company_id
ON accounting_periods(company_id);

CREATE INDEX idx_accounting_periods_status
ON accounting_periods(status);

CREATE INDEX idx_company_accounts_company_id
ON company_accounts(company_id);

CREATE INDEX idx_company_accounts_type
ON company_accounts(account_type);

CREATE INDEX idx_company_accounts_active
ON company_accounts(is_active);