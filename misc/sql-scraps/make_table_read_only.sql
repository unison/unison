/*
 * make_table_read_only(<schema_name>,<table_name>)
 * checks for non read permissions for each user in v_table_perms
 * also checks for non-read permissions for public
 * $ID = q$Id$;
 */
create or replace function unison.make_table_read_only(name,name)
returns bool as '
declare
	schema alias for $1;
	table alias for $2;
	perm_letter char[] := ''{w,a,d,x,t,R}'';
	var boolean;
	users name[];
	i integer;
begin
	-- all users
	select into users get_current_users(schema,table);
	FOR i IN array_lower(users, 1)..array_upper(users, 1) LOOP
		IF check_user_perms(users[i],schema,table,perm_letter) THEN
			EXECUTE ''REVOKE UPDATE, INSERT, DELETE, REFERENCES, TRIGGER, RULE ON ''|| schema||''.''||table ||'' FROM '' || users[i];
		END IF;

	END LOOP;

	-- public
	IF check_public_perms(schema,table,perm_letter) THEN
		EXECUTE ''REVOKE UPDATE, INSERT, DELETE, REFERENCES, TRIGGER, RULE ON ''|| schema||''.''||table ||'' FROM PUBLIC'';
	END IF;

return true;
end;'
language 'plpgsql';

COMMENT ON FUNCTION make_table_read_only(name,name) IS 'make_table_read_only(<schema_name>,<table_name>) checks and revokes wadxRt permissions for each user and public';
