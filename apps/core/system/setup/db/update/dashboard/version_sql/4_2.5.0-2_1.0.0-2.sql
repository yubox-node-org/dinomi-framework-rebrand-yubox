DELETE FROM applet WHERE name = "System Resources";
DELETE FROM applet WHERE name = "Performance Graphic";

DELETE FROM default_applet_by_user WHERE id_applet = 1;
DELETE FROM default_applet_by_user WHERE id_applet = 4;

DELETE FROM activated_applet_by_user WHERE id_dabu = 1;
DELETE FROM activated_applet_by_user WHERE id_dabu = 4;
