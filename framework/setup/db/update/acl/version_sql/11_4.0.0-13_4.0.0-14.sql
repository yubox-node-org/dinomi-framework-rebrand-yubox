-- ----------------------------------------------------------------------------
-- Table acl.acl_module_privileges
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `acl`.`acl_module_privileges` (
  `id` INT NOT NULL,
  `id_resource` INT NOT NULL,
  `privilege` LONGTEXT NOT NULL,
  `desc_privilege` LONGTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (id_resource) REFERENCES acl_resource(id)
);

-- ----------------------------------------------------------------------------
-- Table acl.acl_module_user_permissions
-- ----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `acl`.`acl_module_user_permissions` (
  `id` INT NOT NULL,
  `id_user` INT NOT NULL,
  `id_module_privilege` INT NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (id_user) REFERENCES acl_user(id),
  FOREIGN KEY (id_module_privilege) REFERENCES acl_module_privileges(id)
);

-- ----------------------------------------------------------------------------
-- Table acl.acl_module_group_permissions
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `acl`.`acl_module_group_permissions` (
  `id` INT NOT NULL,
  `id_group` INT NOT NULL,
  `id_module_privilege` INT NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (id_group) REFERENCES acl_group(id),
  FOREIGN KEY (id_module_privilege) REFERENCES acl_module_privileges(id)
);
