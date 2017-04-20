DELETE FROM applet WHERE name = "Processes Status";
DELETE FROM applet WHERE name = "Performance Graphic";

DELETE FROM default_applet_by_user WHERE id_applet = 2;
DELETE FROM default_applet_by_user WHERE id_applet = 4;

DELETE FROM activated_applet_by_user WHERE id_dabu = 2;
DELETE FROM activated_applet_by_user WHERE id_dabu = 4;
