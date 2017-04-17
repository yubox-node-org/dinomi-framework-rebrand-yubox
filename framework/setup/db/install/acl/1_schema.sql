SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------------------------------------------------------
-- Schema acl
-- ----------------------------------------------------------------------------
DROP SCHEMA IF EXISTS `acl` ;
CREATE SCHEMA IF NOT EXISTS `acl` ;

use acl;
-- ----------------------------------------------------------------------------
-- Table acl.acl_action
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `acl`.`acl_action` (
  `description` LONGTEXT NULL DEFAULT NULL,
  `id` INT NOT NULL,
  `name` LONGTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id`))ENGINE=InnoDB;

INSERT INTO acl_action (description,id,name) VALUES('Access the resource',1,'access');

-- ----------------------------------------------------------------------------
-- Table acl.acl_group
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `acl`.`acl_group` (
  `description` LONGTEXT NULL DEFAULT NULL,
  `id` INT NOT NULL,
  `name` LONGTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id`))ENGINE=InnoDB;

INSERT INTO acl_group (description,id,name) VALUES('total access',1,'administrator');
INSERT INTO acl_group (description,id,name) VALUES('extension user',3,'extension');

-- ----------------------------------------------------------------------------
-- Table acl.acl_membership
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `acl`.`acl_membership` (
  `id` INT NOT NULL,
  `id_user` INT NOT NULL DEFAULT 0,
  `id_group` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`))ENGINE=InnoDB;

INSERT INTO acl_membership (id,id_user,id_group) VALUES(1,1,1);

-- ----------------------------------------------------------------------------
-- Table acl.acl_user
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `acl`.`acl_user` (
  `id` INT NOT NULL,
  `name` LONGTEXT NULL DEFAULT NULL,
  `description` LONGTEXT NULL DEFAULT NULL,
  `md5_password` LONGTEXT NULL DEFAULT NULL,
  `extension` LONGTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id`))ENGINE=InnoDB;

INSERT INTO acl_user (id,name,description,md5_password,extension) VALUES(1,'admin',NULL,'7a5210c173ea40c03205a5de7dcd4cb0',NULL);

-- ----------------------------------------------------------------------------
-- Table acl.acl_user_permission
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `acl`.`acl_user_permission` (
  `id` INT NOT NULL,
  `id_action` INT NULL DEFAULT NULL,
  `id_user` INT NULL DEFAULT NULL,
  `id_resource` INT NULL DEFAULT NULL,
  PRIMARY KEY (`id`))ENGINE=InnoDB;

-- ----------------------------------------------------------------------------
-- Table acl.acl_resource
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `acl`.`acl_resource` (
  `id` INT NOT NULL,
  `name` LONGTEXT NULL DEFAULT NULL,
  `description` LONGTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id`))ENGINE=InnoDB;

INSERT INTO acl_resource (id,name,description) VALUES(1,'sysinfo','System Info');
INSERT INTO acl_resource (id,name,description) VALUES(2,'usermgr','User Management');
INSERT INTO acl_resource (id,name,description) VALUES(3,'grouplist','Group List');
INSERT INTO acl_resource (id,name,description) VALUES(4,'userlist','User List');
INSERT INTO acl_resource (id,name,description) VALUES(5,'group_permission','Group Permission');
INSERT INTO acl_resource (id,name,description) VALUES(6,'load_module','Load Module');
INSERT INTO acl_resource (id,name,description) VALUES(16,'preferences','Preferences');
INSERT INTO acl_resource (id,name,description) VALUES(17,'language','Language');
INSERT INTO acl_resource (id,name,description) VALUES(18,'themes_system','Themes');
INSERT INTO acl_resource (id,name,description) VALUES(19,'time_config','Date/Time');
INSERT INTO acl_resource (id,name,description) VALUES(20,'example','Example');

-- ----------------------------------------------------------------------------
-- Table acl.acl_group_permission
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `acl`.`acl_group_permission` (
  `id` INT NOT NULL,
  `id_action` INT NOT NULL,
  `id_group` INT NOT NULL,
  `id_resource` INT NOT NULL,
  PRIMARY KEY (`id`))ENGINE=InnoDB;

INSERT INTO acl_group_permission (id,id_action,id_group,id_resource) VALUES(1,1,1,1);
INSERT INTO acl_group_permission (id,id_action,id_group,id_resource) VALUES(2,1,1,2);
INSERT INTO acl_group_permission (id,id_action,id_group,id_resource) VALUES(3,1,1,3);
INSERT INTO acl_group_permission (id,id_action,id_group,id_resource) VALUES(4,1,1,4);
INSERT INTO acl_group_permission (id,id_action,id_group,id_resource) VALUES(5,1,1,5);
INSERT INTO acl_group_permission (id,id_action,id_group,id_resource) VALUES(6,1,1,6);
INSERT INTO acl_group_permission (id,id_action,id_group,id_resource) VALUES(7,1,1,16);
INSERT INTO acl_group_permission (id,id_action,id_group,id_resource) VALUES(8,1,1,17);
INSERT INTO acl_group_permission (id,id_action,id_group,id_resource) VALUES(9,1,1,18);
INSERT INTO acl_group_permission (id,id_action,id_group,id_resource) VALUES(10,1,1,19);
INSERT INTO acl_group_permission (id,id_action,id_group,id_resource) VALUES(11,1,3,1);
INSERT INTO acl_group_permission (id,id_action,id_group,id_resource) VALUES(12,1,3,16);
INSERT INTO acl_group_permission (id,id_action,id_group,id_resource) VALUES(13,1,3,17);
INSERT INTO acl_group_permission (id,id_action,id_group,id_resource) VALUES(14,1,3,18);
INSERT INTO acl_group_permission (id,id_action,id_group,id_resource) VALUES(15,1,3,19);
INSERT INTO acl_group_permission (id,id_action,id_group,id_resource) VALUES(16,1,1,20);

GRANT SELECT, UPDATE, INSERT, DELETE ON `acl`.* to root@localhost;
