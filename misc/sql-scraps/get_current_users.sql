/*
 * get_current_users ( <schema name>, <relation name>);
 * returns a name[] array of current users of the input schema,table
 * $ID = q$Id$;
 */
create or replace function unison.get_current_users(name, name)
returns name[] as '
declare
  schema alias for $1;
  table alias for $2;
  current_users name[] = ''{}'';
  pguser record;
  acl text;
  user text;
  rec record;
begin
  for pguser in select usename from pg_user LOOP
	for rec in select perms FROM v_table_perms WHERE schemaname = schema AND tablename = table LOOP
		acl := rec.perms;
		user := pguser.usename||''='';
	  	IF acl ~ user THEN
			current_users = array_append(current_users,pguser.usename);
			EXIT;
	  	END IF;
	END LOOP;
  END LOOP;
  RETURN current_users;
end;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION get_current_users(name, name) IS 'get_current_users(<schema_name>, <table_name>) returns a name[] array of current users of the input schema,table';
