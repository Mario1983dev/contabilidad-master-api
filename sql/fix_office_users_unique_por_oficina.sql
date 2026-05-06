USE contabilidad_master;

ALTER TABLE office_users DROP INDEX uq_office_users_email;
ALTER TABLE office_users DROP INDEX uq_office_users_username;

ALTER TABLE office_users ADD UNIQUE unique_office_username (office_id, username);
ALTER TABLE office_users ADD UNIQUE unique_office_email (office_id, email);