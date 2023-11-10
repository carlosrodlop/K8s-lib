DROP USER IF EXISTS 'flow'@'%';

DROP DATABASE IF EXISTS flow;
DROP DATABASE IF EXISTS flow_upgrade;

SHOW DATABASES;
Select user from mysql.user;
