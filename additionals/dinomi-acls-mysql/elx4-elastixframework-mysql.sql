CREATE DATABASE `elxframework`;

GRANT SELECT, INSERT, UPDATE, DELETE ON `elxframework`.* TO elxframework@localhost ;

USE `elxframework`;

CREATE TABLE `settings`
(
    `key`           VARCHAR(32),
    `value`         VARCHAR(32),

    PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `menu`
(
    `id`        VARCHAR(64),
    `IdParent`  VARCHAR(64),
    `Link`      VARCHAR(250),
    `Name`      VARCHAR(250),
    `Type`      VARCHAR(20),
    `order_no`  INT,

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `acl_action`
(
    `description`   VARCHAR(200)    NOT NULL,
    `id`            INT             NOT NULL    AUTO_INCREMENT,
    `name`          VARCHAR(10)     NOT NULL,

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `acl_resource`
(
    `id`            INT             NOT NULL    AUTO_INCREMENT,
    `name`          VARCHAR(64)     NOT NULL,
    `description`   VARCHAR(180)    NOT NULL,

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `acl_module_privileges`
(
    `id`                INT             NOT NULL AUTO_INCREMENT,
    `id_resource`       INT             NOT NULL,
    `privilege`         VARCHAR(32)     NOT NULL,
    `desc_privilege`    TEXT,

    PRIMARY KEY (`id`),
    FOREIGN KEY (`id_resource`) REFERENCES `acl_resource` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `acl_user`
(
    `id`            INT             NOT NULL AUTO_INCREMENT,
    `name`          VARCHAR(50)     NOT NULL,
    `description`   VARCHAR(180),
    `md5_password`  VARCHAR(50)     NOT NULL,
    `extension`     VARCHAR(20),

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `acl_user_permission`
(
    `id`            INT             NOT NULL AUTO_INCREMENT,
    `id_action`     INT             NOT NULL,
    `id_user`       INT             NOT NULL,
    `id_resource`   INT             NOT NULL,

    PRIMARY KEY (`id`),
    FOREIGN KEY (`id_action`) REFERENCES `acl_action` (`id`),
    FOREIGN KEY (`id_user`) REFERENCES `acl_user` (`id`),
    FOREIGN KEY (`id_resource`) REFERENCES `acl_resource` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `acl_module_user_permissions`
(
    `id`            INT             NOT NULL AUTO_INCREMENT,
    `id_user`       INT             NOT NULL,
    `id_module_privilege`   INT     NOT NULL,

    PRIMARY KEY (`id`),
    FOREIGN KEY (`id_user`) REFERENCES `acl_user` (`id`),
    FOREIGN KEY (`id_module_privilege`) REFERENCES `acl_module_privileges` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `acl_user_shortcut`
(
    `id`            INT         NOT NULL AUTO_INCREMENT,
    `id_user`       INT         NOT NULL,
    `id_resource`   INT         NOT NULL,
    `type`          VARCHAR(25) NOT NULL,
    `description`   VARCHAR(25),

    PRIMARY KEY (`id`),
    FOREIGN KEY (`id_user`) REFERENCES `acl_user` (`id`),
    FOREIGN KEY (`id_resource`) REFERENCES `acl_resource` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `sticky_note`
(
    `id`            INT         NOT NULL AUTO_INCREMENT,
    `id_user`       INT         NOT NULL,
    `id_resource`   INT         NOT NULL,
    `date_edit`     DATETIME    NOT NULL,
    `description`   TEXT,
    `auto_popup`    INT         NOT NULL DEFAULT '0',

    PRIMARY KEY (`id`),
    FOREIGN KEY (`id_user`) REFERENCES `acl_user` (`id`),
    FOREIGN KEY (`id_resource`) REFERENCES `acl_resource` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `acl_notification`
(
    `id`                INT         NOT NULL,
    `datetime_create`   DATETIME    NOT NULL,
    `level`             VARCHAR(32) NOT NULL DEFAULT 'info',
    `id_user`           INT,
    `id_resource`       INT,
    `content`           TEXT,

    PRIMARY KEY (`id`),
    FOREIGN KEY (`id_user`) REFERENCES `acl_user` (`id`),
    FOREIGN KEY (`id_resource`) REFERENCES `acl_resource` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `acl_group`
(
    `description`   TEXT,
    `id`            INT         NOT NULL    AUTO_INCREMENT,
    `name`          VARCHAR(200),

    PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `acl_group_permission`
(
    `id`            INT         NOT NULL    AUTO_INCREMENT,
    `id_action`     INT         NOT NULL,
    `id_group`      INT         NOT NULL,
    `id_resource`   INT         NOT NULL,

    PRIMARY KEY (`id`),
    FOREIGN KEY (`id_action`) REFERENCES `acl_action` (`id`),
    FOREIGN KEY (`id_group`) REFERENCES `acl_group` (`id`),
    FOREIGN KEY (`id_resource`) REFERENCES `acl_resource` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `acl_module_group_permissions`
(
    `id`            INT         NOT NULL AUTO_INCREMENT,
    `id_group`      INT         NOT NULL,
    `id_module_privilege`   INT NOT NULL,

    PRIMARY KEY (`id`),
    FOREIGN KEY (`id_group`) REFERENCES `acl_group` (`id`),
    FOREIGN KEY (`id_module_privilege`) REFERENCES `acl_module_privileges` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `acl_membership`
(
    `id`            INT         NOT NULL AUTO_INCREMENT,
    `id_user`       INT         NOT NULL,
    `id_group`      INT         NOT NULL,

    PRIMARY KEY (`id`),
    FOREIGN KEY (`id_user`) REFERENCES `acl_user` (`id`),
    FOREIGN KEY (`id_group`) REFERENCES `acl_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


/* Las siguientes tablas las crea en acl.db el módulo elastix-system */
CREATE TABLE `acl_user_profile`
(
    `id_profile`    INT         NOT NULL AUTO_INCREMENT,
    `id_user`       INT         NOT NULL,
    `id_resource`   INT         NOT NULL,
    `profile`       VARCHAR(32) NOT NULL,

    PRIMARY KEY (`id_profile`),
    FOREIGN KEY (`id_user`) REFERENCES `acl_user` (`id`),
    FOREIGN KEY (`id_resource`) REFERENCES `acl_resource` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `acl_profile_properties`
(
    `id_profile`    INT         NOT NULL AUTO_INCREMENT,
    `property`      VARCHAR(32) NOT NULL,
    `value`         VARCHAR(256),

    PRIMARY KEY (`id_profile`,`property`),
    FOREIGN KEY (`id_profile`) REFERENCES `acl_user_profile` (`id_profile`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


