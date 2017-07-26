PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE menu (
    id          varchar(40),
    IdParent    varchar(40),
    Link        varchar(250),
    Name        varchar(250),
    Type        varchar(20),
    order_no    Integer
);
INSERT INTO "menu" VALUES('system','','','System','', 1);
INSERT INTO "menu" VALUES('usermgr','system','usermgr','User Management','module', 4);
INSERT INTO "menu" VALUES('grouplist','usermgr','','Groups','module', 42);
INSERT INTO "menu" VALUES('userlist','usermgr','','Users','module', 41);
INSERT INTO "menu" VALUES('group_permission','usermgr','','Group Permission','module', 43);
INSERT INTO "menu" VALUES('preferences','system','','Preferences','module', 10);
INSERT INTO "menu" VALUES('language','preferences','','Language','module', 101);
INSERT INTO "menu" VALUES('themes_system','preferences','','Themes','module', 103);

COMMIT;
