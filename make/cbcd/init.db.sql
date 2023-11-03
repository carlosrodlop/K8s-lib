CREATE DATABASE flow CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE DATABASE flow_upgrade CHARACTER SET utf8 COLLATE utf8_general_ci;

CREATE USER 'flow'@'%' IDENTIFIED WITH mysql_native_password BY 'flow';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, INDEX, DROP, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES ON flow.* TO 'flow'@'%';
GRANT ALL PRIVILEGES ON flow.* TO 'flow'@'%';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, INDEX, DROP, ALTER, CREATE TEMPORARY TABLES, LOCK TABLES ON flow_upgrade.* TO 'flow'@'%';
GRANT ALL PRIVILEGES ON flow_upgrade.* TO 'flow'@'%';
FLUSH PRIVILEGES;
