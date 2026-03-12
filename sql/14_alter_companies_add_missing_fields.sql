USE contabilidad_master;

/* ======================================================
   14_alter_companies_fields.sql
   Agrega campos faltantes a la tabla companies
====================================================== */

ALTER TABLE companies
ADD COLUMN legal_name VARCHAR(200) NULL AFTER name,
ADD COLUMN business_type VARCHAR(100) NULL AFTER legal_name,
ADD COLUMN email VARCHAR(150) NULL AFTER business_type,
ADD COLUMN phone VARCHAR(50) NULL AFTER email,
ADD COLUMN address VARCHAR(255) NULL AFTER phone,
ADD COLUMN commune VARCHAR(100) NULL AFTER address,
ADD COLUMN city VARCHAR(100) NULL AFTER commune,
ADD COLUMN region_name VARCHAR(100) NULL AFTER city,
ADD COLUMN status ENUM('active','inactive') NOT NULL DEFAULT 'active' AFTER region_name,
ADD COLUMN notes VARCHAR(255) NULL AFTER status;

ALTER TABLE companies
ADD COLUMN updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
ON UPDATE CURRENT_TIMESTAMP AFTER created_at;

ALTER TABLE companies
ADD COLUMN commune VARCHAR(100) NULL AFTER address;

ALTER TABLE companies
ADD COLUMN city VARCHAR(100) NULL AFTER commune;

ALTER TABLE companies
ADD COLUMN region_name VARCHAR(100) NULL AFTER city;

ALTER TABLE companies
ADD COLUMN notes VARCHAR(255) NULL AFTER status;

ALTER TABLE companies
MODIFY COLUMN status ENUM('active','inactive') NOT NULL DEFAULT 'active';


ALTER TABLE company_accounts
ADD COLUMN account_type ENUM('ACTIVO','PASIVO','PATRIMONIO','INGRESO','GASTO','RESULTADO') NOT NULL AFTER name,
ADD COLUMN balance_nature ENUM('DEBITO','CREDITO') NOT NULL AFTER account_type,
ADD COLUMN notes VARCHAR(255) NULL AFTER sort_order;
