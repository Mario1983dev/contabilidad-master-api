
-- ============================================
-- BASE DE DATOS: CONTABILIDAD MASTER
-- Sistema de administración central (TENANTS)
-- ============================================

CREATE DATABASE IF NOT EXISTS contabilidad_master;
USE contabilidad_master;

-- Tabla: master_users
CREATE TABLE IF NOT EXISTS master_users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: offices (TENANTS)
CREATE TABLE IF NOT EXISTS offices (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  rut VARCHAR(20),
  plan ENUM('BASIC','PRO','ENTERPRISE') DEFAULT 'BASIC',
  status ENUM('ACTIVE','SUSPENDED','EXPIRED','TRIAL') DEFAULT 'ACTIVE',
  license_until DATE NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: office_admins
CREATE TABLE IF NOT EXISTS office_admins (
  id INT AUTO_INCREMENT PRIMARY KEY,
  office_id INT NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_office_admin
    FOREIGN KEY (office_id)
    REFERENCES offices(id)
    ON DELETE CASCADE
);

-- Tabla: audit_log
CREATE TABLE IF NOT EXISTS audit_log (
  id INT AUTO_INCREMENT PRIMARY KEY,
  actor_type ENUM('MASTER','OFFICE') NOT NULL,
  actor_id INT NOT NULL,
  action VARCHAR(255) NOT NULL,
  entity VARCHAR(100),
  entity_id INT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
