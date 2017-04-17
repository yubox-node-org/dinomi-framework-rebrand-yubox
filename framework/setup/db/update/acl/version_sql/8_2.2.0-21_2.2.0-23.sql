CREATE TABLE IF NOT EXISTS `acl`.`sticky_note` (
  `id` INT NOT NULL,
  `id_user` INT NOT NULL,
  `id_resource` INT NOT NULL,
  `date_edit` DATETIME NOT NULL,
  `description` LONGTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id`));
