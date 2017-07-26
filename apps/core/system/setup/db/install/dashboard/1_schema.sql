BEGIN TRANSACTION;

CREATE TABLE default_applet_by_user(
      id         integer        primary key,
      id_applet  integer        not null,
      username   varchar(100)   not null,
      foreign key(id_applet)    references applet(id)
);
INSERT INTO "default_applet_by_user" VALUES(1, 1, 'admin');
INSERT INTO "default_applet_by_user" VALUES(3, 3, 'admin');
INSERT INTO "default_applet_by_user" VALUES(7, 7, 'admin');
INSERT INTO "default_applet_by_user" VALUES(9, 9, 'admin');
INSERT INTO "default_applet_by_user" VALUES(10, 10, 'admin');
INSERT INTO "default_applet_by_user" VALUES(11, 11, 'admin');
INSERT INTO "default_applet_by_user" VALUES(12, 12, 'admin');
INSERT INTO "default_applet_by_user" VALUES(14, 7, 'no_admin');
INSERT INTO "default_applet_by_user" VALUES(16, 9, 'no_admin');
INSERT INTO "default_applet_by_user" VALUES(17, 10, 'no_admin');
INSERT INTO "default_applet_by_user" VALUES(18, 11, 'no_admin');
INSERT INTO "default_applet_by_user" VALUES(19, 13, 'admin');


CREATE TABLE applet(
      id         integer        primary key,
      code       varchar(100)   not null,
      name       varchar(100),
      icon varchar(50)
);
INSERT INTO "applet" VALUES(1, 'Applet_SystemResources', 'System Resources', 'memory.png');
INSERT INTO "applet" VALUES(3, 'Applet_HardDrives', 'Hard Drives', 'hd.png');
INSERT INTO "applet" VALUES(7, 'Applet_Calendar', 'Calendar', 'calendar.png');
INSERT INTO "applet" VALUES(9, 'Applet_Emails', 'Emails', 'email.png');
INSERT INTO "applet" VALUES(10, 'Applet_Faxes', 'Faxes', 'fax.png');
INSERT INTO "applet" VALUES(11, 'Applet_Voicemails', 'Voicemails', 'voicemail.png');
INSERT INTO "applet" VALUES(12, 'Applet_System', 'System', 'system.png');
INSERT INTO "applet" VALUES(13, 'Applet_TelephonyHardware', 'Telephony Hardware', 'pci.png');


CREATE TABLE activated_applet_by_user(
      id         integer        primary key,
      id_dabu    integer        not null,
      order_no   integer,
      username   varchar(100),
      foreign key(id_dabu)      references default_applet_by_user(id)
);
INSERT INTO "activated_applet_by_user" VALUES(29, 14, 1, 'admin');
INSERT INTO "activated_applet_by_user" VALUES(31, 16, 2, 'admin');
INSERT INTO "activated_applet_by_user" VALUES(32, 17, 3, 'admin');
INSERT INTO "activated_applet_by_user" VALUES(33, 18, 4, 'admin');
INSERT INTO "activated_applet_by_user" VALUES(34, 1, 1, 'admin');
INSERT INTO "activated_applet_by_user" VALUES(36, 3, 3, 'admin');
INSERT INTO "activated_applet_by_user" VALUES(17, 6, 6, 'admin');


COMMIT;
