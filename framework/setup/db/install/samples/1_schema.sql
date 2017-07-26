PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE graph (id INTEGER PRIMARY KEY, name varchar(200));
INSERT INTO "graph" VALUES(1,'Simultaneous calls, memory and CPU');
INSERT INTO "graph" VALUES(2,'Simultaneous Channels (Total)');
INSERT INTO "graph" VALUES(3,'Simultaneous Zap Channels');
INSERT INTO "graph" VALUES(4,'Simultaneous SIP Channels');
INSERT INTO "graph" VALUES(5,'Simultaneous IAX Channels');
INSERT INTO "graph" VALUES(6,'Simultaneous H323 Channels');
INSERT INTO "graph" VALUES(7,'Simultaneous Local Channels');
CREATE TABLE graph_vs_line (id INTEGER PRIMARY KEY, id_graph integer, id_line integer);
INSERT INTO "graph_vs_line" VALUES(1,1,1);
INSERT INTO "graph_vs_line" VALUES(2,1,2);
INSERT INTO "graph_vs_line" VALUES(3,1,3);
INSERT INTO "graph_vs_line" VALUES(4,2,4);
INSERT INTO "graph_vs_line" VALUES(5,3,5);
INSERT INTO "graph_vs_line" VALUES(6,4,6);
INSERT INTO "graph_vs_line" VALUES(7,5,7);
INSERT INTO "graph_vs_line" VALUES(8,6,8);
INSERT INTO "graph_vs_line" VALUES(9,7,9);
CREATE TABLE line (color varchar(20), id INTEGER PRIMARY KEY, line_type varchar(20), name varchar(200));
INSERT INTO "line" VALUES('#00cc00',1,'1','Sim. calls');
INSERT INTO "line" VALUES('#0000cc',2,'0','CPU usage (%)');
INSERT INTO "line" VALUES('#cc0000',3,'0','Mem. usage (MB)');
INSERT INTO "line" VALUES('#0000cc',4,'0','Total Channels');
INSERT INTO "line" VALUES('#0000cc',5,'0','Zap Channels');
INSERT INTO "line" VALUES('#0000cc',6,'0','SIP Channels');
INSERT INTO "line" VALUES('#0000cc',7,'0','IAX Channels');
INSERT INTO "line" VALUES('#0000cc',8,'0','H323 Channels');
INSERT INTO "line" VALUES('#0000cc',9,'0','Local Channels');
CREATE TABLE samples (id INTEGER PRIMARY KEY, id_line integer, timestamp timestamp, value varchar(200));
COMMIT;
