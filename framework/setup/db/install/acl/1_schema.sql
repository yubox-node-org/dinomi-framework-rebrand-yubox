PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE acl_action (
    description varchar(200),
    id          INTEGER PRIMARY KEY,
    name        varchar(10)
);
INSERT INTO "acl_action" VALUES('Access the resource',1,'access');
INSERT INTO "acl_action" VALUES('View the resource',2,'view');
INSERT INTO "acl_action" VALUES('Create into resource',3,'create');
INSERT INTO "acl_action" VALUES('Delete in resource',4,'delete');
INSERT INTO "acl_action" VALUES('Update into resource',5,'update');

CREATE TABLE acl_group (
    description TEXT,
    id          INTEGER PRIMARY KEY,
    name        varchar(200)
);
INSERT INTO "acl_group" VALUES('total access',1,'administrator');

CREATE TABLE acl_membership (
    id          INTEGER NOT NULL   PRIMARY KEY,
    id_user     INTEGER NOT NULL default '0',
    id_group    INTEGER NOT NULL default '0'
);
INSERT INTO "acl_membership" VALUES(1,1,1);

CREATE TABLE acl_user (
    id          INTEGER PRIMARY KEY,
    name        varchar(50),
    description varchar(180),
    md5_password varchar(50),
    extension   varchar(20)
);
INSERT INTO "acl_user" VALUES(1,'admin',NULL,'7a5210c173ea40c03205a5de7dcd4cb0',NULL);

CREATE TABLE acl_user_permission (
    id          INTEGER PRIMARY KEY,
    id_action   int(11),
    id_user     int(11),
    id_resource int(11)
);

CREATE TABLE acl_resource (
    id          INTEGER PRIMARY KEY,
    name        varchar(50),
    description varchar(180)
);
INSERT INTO "acl_resource" VALUES(2,'usermgr','User Management');
INSERT INTO "acl_resource" VALUES(3,'grouplist','Group List');
INSERT INTO "acl_resource" VALUES(4,'userlist','User List');
INSERT INTO "acl_resource" VALUES(5,'group_permission','Group Permission');
INSERT INTO "acl_resource" VALUES(16,'preferences','Preferences');
INSERT INTO "acl_resource" VALUES(17,'language','Language');
INSERT INTO "acl_resource" VALUES(18,'themes_system','Themes');

CREATE TABLE acl_group_permission (
    id          INTEGER NOT NULL PRIMARY KEY,
    id_action   INTEGER NOT NULL,
    id_group    INTEGER NOT NULL,
    id_resource INTEGER NOT NULL
);
INSERT INTO "acl_group_permission" VALUES(2,1,1,2);
INSERT INTO "acl_group_permission" VALUES(3,1,1,3);
INSERT INTO "acl_group_permission" VALUES(4,1,1,4);
INSERT INTO "acl_group_permission" VALUES(5,1,1,5);
INSERT INTO "acl_group_permission" VALUES(7,1,1,16);
INSERT INTO "acl_group_permission" VALUES(8,1,1,17);
INSERT INTO "acl_group_permission" VALUES(9,1,1,18);

CREATE TABLE acl_user_shortcut(
       id           INTEGER     NOT NULL   PRIMARY KEY,
       id_user      INTEGER     NOT NULL,
       id_resource  INTEGER     NOT NULL,
       type         VARCHAR(25) NOT NULL,
       description  VARCHAR(25)
);

CREATE TABLE sticky_note(
       id           INTEGER   NOT NULL   PRIMARY KEY,
       id_user      INTEGER   NOT NULL,
       id_resource  INTEGER   NOT NULL,
       date_edit    DATETIME  NOT NULL,
       description  TEXT,
       auto_popup INTEGER NOT NULL DEFAULT '0'
);

CREATE TABLE acl_notification
(
    id              INTEGER     NOT NULL    PRIMARY KEY,
    datetime_create DATETIME    NOT NULL,
    level           VARCHAR(32) NOT NULL    DEFAULT 'info',
    id_user         INTEGER,
    id_resource     INTEGER,
    content         TEXT,

    FOREIGN KEY (id_user) REFERENCES acl_user(id),
    FOREIGN KEY (id_resource) REFERENCES acl_resource(id)
);

CREATE TABLE acl_module_privileges (
    id              INTEGER     NOT NULL    PRIMARY KEY,
    id_resource     INTEGER     NOT NULL,
    privilege       VARCHAR(32) NOT NULL,
    desc_privilege  TEXT,

    FOREIGN KEY (id_resource) REFERENCES acl_resource(id)
);

CREATE TABLE acl_module_user_permissions (
    id                  INTEGER     NOT NULL    PRIMARY KEY,
    id_user             INTEGER     NOT NULL,
    id_module_privilege INTEGER     NOT NULL,

    FOREIGN KEY (id_user) REFERENCES acl_user(id),
    FOREIGN KEY (id_module_privilege) REFERENCES acl_module_privileges(id)
);

CREATE TABLE acl_module_group_permissions (
    id                  INTEGER     NOT NULL    PRIMARY KEY,
    id_group            INTEGER     NOT NULL,
    id_module_privilege INTEGER     NOT NULL,

    FOREIGN KEY (id_group) REFERENCES acl_group(id),
    FOREIGN KEY (id_module_privilege) REFERENCES acl_module_privileges(id)
);

COMMIT;
