BEGIN TRANSACTION;
DELETE FROM acl_group_permission WHERE id_resource LIKE (SELECT id FROM acl_resource WHERE name='example');
DELETE FROM acl_resource WHERE name='example';
COMMIT;
