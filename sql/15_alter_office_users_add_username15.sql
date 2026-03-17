ALTER TABLE office_users
ADD COLUMN username VARCHAR(50) NULL AFTER office_id;

UPDATE office_users
SET username = SUBSTRING_INDEX(email, '@', 1)
WHERE username IS NULL
  AND email IS NOT NULL
  AND email <> '';

ALTER TABLE office_users
MODIFY COLUMN username VARCHAR(50) NOT NULL;

ALTER TABLE office_users
ADD CONSTRAINT uq_office_users_username UNIQUE (username);

ALTER TABLE office_admins
ADD COLUMN username VARCHAR(50);
