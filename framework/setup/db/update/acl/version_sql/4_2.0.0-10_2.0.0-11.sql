BEGIN TRANSACTION;
DELETE FROM acl_group_permission WHERE id_resource LIKE (SELECT id FROM acl_resource WHERE name='sysinfo');
DELETE FROM acl_resource WHERE name='sysinfo';
COMMIT;
