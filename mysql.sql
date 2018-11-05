GRANT ALL ON laravelspace.* TO 'root'@'localhost' IDENTIFIED BY 'root';
GRANT ALL ON laravelspace.* TO 'root'@ IDENTIFIED BY 'root';

GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;
FLUSH PRIVILEGES;

GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'ph012916956!';

CREATE DATABASE `lexscorp_core_db` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;

## Create user and privileges

CREATE USER 'srphlaravelspaces'@'localhost' IDENTIFIED BY 'ph012916956!';

GRANT ALL PRIVILEGES ON *.* TO 'srphlaravelspaces'@'localhost';

GRANT ALL PRIVILEGES ON laravelspace.* TO 'srphlaravelspaces'@'%' IDENTIFIED BY 'ph012916956!';

FLUSH PRIVILEGES;