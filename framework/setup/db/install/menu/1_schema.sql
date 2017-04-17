SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------------------------------------------
-- Schema menu
-- ----------------------------------------------------------------------------
DROP SCHEMA IF EXISTS `menu` ;
CREATE SCHEMA IF NOT EXISTS `menu` ;

use menu;

CREATE TABLE IF NOT EXISTS `menu`.`menu` (
  `id` LONGTEXT NULL DEFAULT NULL,
  `IdParent` LONGTEXT NULL DEFAULT NULL,
  `Link` LONGTEXT NULL DEFAULT NULL,
  `Name` LONGTEXT NULL DEFAULT NULL,
  `Type` LONGTEXT NULL DEFAULT NULL);
SET FOREIGN_KEY_CHECKS = 1;

INSERT INTO menu (id,IdParent,Link,Name,Type) VALUES('system','','','System','');
INSERT INTO menu (id,IdParent,Link,Name,Type) VALUES('sysinfo','system','sysinfo','System Info','module');
INSERT INTO menu (id,IdParent,Link,Name,Type) VALUES('usermgr','system','usermgr','User Management','module');
INSERT INTO menu (id,IdParent,Link,Name,Type) VALUES('grouplist','usermgr','','Groups','module');
INSERT INTO menu (id,IdParent,Link,Name,Type) VALUES('userlist','usermgr','','Users','module');
INSERT INTO menu (id,IdParent,Link,Name,Type) VALUES('group_permission','usermgr','','Group Permission','module');
INSERT INTO menu (id,IdParent,Link,Name,Type) VALUES('load_module','system','','Load Module','module');
INSERT INTO menu (id,IdParent,Link,Name,Type) VALUES('preferences','system','','Preferences','module');
INSERT INTO menu (id,IdParent,Link,Name,Type) VALUES('language','preferences','','Language','module');
INSERT INTO menu (id,IdParent,Link,Name,Type) VALUES('time_config','preferences','','Date/Time','module');
INSERT INTO menu (id,IdParent,Link,Name,Type) VALUES('themes_system','preferences','','Themes','module');
INSERT INTO menu (id,IdParent,Link,Name,Type) VALUES('example','system','','Example','module');
