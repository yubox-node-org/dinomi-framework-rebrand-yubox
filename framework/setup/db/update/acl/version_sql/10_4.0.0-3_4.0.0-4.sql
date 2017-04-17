CREATE TABLE IF NOT EXISTS `acl`.`acl_notification` (
  `id` INT NOT NULL,
  `datetime_create` DATETIME NOT NULL,
  `level` VARCHAR(32) NOT NULL DEFAULT 'info',
  `id_user` INT NULL DEFAULT NULL,
  `id_resource` INT NULL DEFAULT NULL,
  `content` LONGTEXT NULL DEFAULT NULL,
   PRIMARY KEY (`id`),
   FOREIGN KEY (id_user) REFERENCES acl_user(id),
   FOREIGN KEY (id_resource) REFERENCES acl_resource(id)
);
