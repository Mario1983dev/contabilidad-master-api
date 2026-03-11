USE contabilidad_master;

/* ======================================================
   10_create_companies.sql
====================================================== */

CREATE TABLE IF NOT EXISTS companies (
  id INT AUTO_INCREMENT PRIMARY KEY,
  office_id INT NOT NULL,
  rut VARCHAR(20) NOT NULL,
  name VARCHAR(150) NOT NULL,
  legal_name VARCHAR(200) NULL,
  business_type VARCHAR(100) NULL,
  email VARCHAR(150) NULL,
  phone VARCHAR(50) NULL,
  address VARCHAR(255) NULL,
  commune VARCHAR(100) NULL,
  city VARCHAR(100) NULL,
  region_name VARCHAR(100) NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  notes VARCHAR(255) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

  CONSTRAINT fk_companies_office
    FOREIGN KEY (office_id) REFERENCES offices(id),

  CONSTRAINT uq_companies_rut_per_office
    UNIQUE (office_id, rut)
);