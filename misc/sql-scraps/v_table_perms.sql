/*
 * v_table_perms.sql 
 * base view on which a lot of other functions depend
 * $ID = q$Id$;
 */

CREATE VIEW v_table_perms as
SELECT n.nspname AS schemaname, c.relname AS tablename, pg_get_userbyid(c.relowner) AS tableowner, c.relacl as perms
FROM pg_class c
LEFT JOIN pg_namespace n  ON n.oid = c.relnamespace
WHERE c.relkind = 'r' order by n.nspname,c.relname
;
