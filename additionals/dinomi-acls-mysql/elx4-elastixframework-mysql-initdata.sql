USE `elxframework`;

INSERT INTO `acl_action` VALUES('Access the resource',1,'access');
INSERT INTO `acl_action` VALUES('View the resource',2,'view');
INSERT INTO `acl_action` VALUES('Create into resource',3,'create');
INSERT INTO `acl_action` VALUES('Delete in resource',4,'delete');
INSERT INTO `acl_action` VALUES('Update into resource',5,'update');

INSERT INTO `acl_user` VALUES(1,'admin',NULL,'7a5210c173ea40c03205a5de7dcd4cb0',NULL);
INSERT INTO `acl_group` VALUES('total access',1,'administrator');
INSERT INTO `acl_membership` VALUES(1,1,1);

