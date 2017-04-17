CREATE TABLE IF NOT EXISTS `acl`.`acl_user_shortcut` (
  `id` INT NOT NULL,
  `id_user` INT NOT NULL,
  `id_resource` INT NOT NULL,
  `type` LONGTEXT NOT NULL,
  `description` LONGTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id`));
