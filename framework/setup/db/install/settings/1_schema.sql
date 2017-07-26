PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE settings (
    key     varchar(32),
    value   varchar(32)
);
INSERT INTO "settings" VALUES('language','en');
INSERT INTO "settings" VALUES('default_rate','0.50');
INSERT INTO "settings" VALUES('default_rate_offset','1');
INSERT INTO "settings" VALUES('elastix_version_release','2.0.0');
INSERT INTO "settings" VALUES('theme','tenant');
INSERT INTO "settings" VALUES('currency','$');
COMMIT;
