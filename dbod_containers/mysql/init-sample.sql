-- Owner account
CREATE USER 'admin'@'%' IDENTIFIED BY 'pass';
GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;
ALTER USER 'admin'@'%' PASSWORD EXPIRE;

-- dod_mysql
CREATE USER 'super_mysql'@'%' IDENTIFIED BY 'superpass';
GRANT ALL PRIVILEGES ON *.* TO 'super_mysql'@'%' WITH GRANT OPTION;

-- Set the password for root and anonymous user (same as super_mysql). Required for MySQL 5.7.x
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('superpass');

FLUSH PRIVILEGES;
