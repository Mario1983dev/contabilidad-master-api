USE contabilidad_master;

ALTER TABLE office_users DROP INDEX uq_office_users_email;
ALTER TABLE office_users DROP INDEX uq_office_users_username;

ALTER TABLE office_users ADD UNIQUE unique_office_username (office_id, username);
ALTER TABLE office_users ADD UNIQUE unique_office_email (office_id, email);

CREATE TABLE libro_cv (
    id INT AUTO_INCREMENT PRIMARY KEY,
    company_id INT NOT NULL,
    periodo VARCHAR(7) NOT NULL, -- ejemplo: 2026-04
    tipo_libro ENUM('COMPRA', 'VENTA') NOT NULL,
    archivo_nombre VARCHAR(255),
    fecha_importacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_company_periodo (company_id, periodo),

    CONSTRAINT fk_libro_cv_company
        FOREIGN KEY (company_id)
        REFERENCES companies(id)
        ON DELETE CASCADE
);

CREATE TABLE libro_cv_detalle (
    id INT AUTO_INCREMENT PRIMARY KEY,
    libro_cv_id INT NOT NULL,

    tipo_documento VARCHAR(100),
    total_documentos INT DEFAULT 0,

    monto_exento DECIMAL(15,2) DEFAULT 0,
    monto_neto DECIMAL(15,2) DEFAULT 0,

    iva_recuperable DECIMAL(15,2) DEFAULT 0,
    iva_uso_comun DECIMAL(15,2) DEFAULT 0,
    iva_no_recuperable DECIMAL(15,2) DEFAULT 0,

    monto_iva DECIMAL(15,2) DEFAULT 0,
    monto_total DECIMAL(15,2) DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_libro_cv (libro_cv_id),

    CONSTRAINT fk_libro_cv_detalle
        FOREIGN KEY (libro_cv_id)
        REFERENCES libro_cv(id)
        ON DELETE CASCADE
);