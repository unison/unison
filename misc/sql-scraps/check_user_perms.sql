/*
 * check_user_perms ( <user name>, <schema name>, <relation name>, <mode flag array> );
 * <mode flag array> consists of letters 'w', 'r', 'a', 'R', 'x' OR 't'
 * $ID = q$Id$;
 */
CREATE OR REPLACE FUNCTION unison.check_user_perms ( name, name, name, char[] ) RETURNS bool AS '
DECLARE
  user alias for $1;
  schema alias for $2;
  table alias for $3;
  privs alias for $4;
  acl text;
  rec record;
  i integer;
BEGIN
  -- check if the input array has the right permission letters
  FOR i IN array_lower(privs, 1)..array_upper(privs, 1) LOOP  
  IF ( privs[i] NOT IN ( ''w'',''r'',''a'',''R'',''x'',''t'',''d'' ) ) THEN
    RAISE EXCEPTION ''mode flags must use single letter from "rwadRxt"'';
  END IF;
  END LOOP;

  SELECT INTO rec tableowner, tablename, schemaname, perms,  usesuper 
  FROM v_table_perms, pg_user 
  WHERE schemaname = schema AND tablename = table;
  
  IF NOT FOUND THEN
    RAISE EXCEPTION ''Did not find either a schema named "%" or a table named "%".'', schema,table;
  END IF;
  
  IF rec.tableowner = user OR rec.usesuper THEN
    RETURN true;
  END IF;
  
  acl := rec.perms;

  IF acl IS NULL THEN
    RETURN false;
  END IF;

  FOR i IN array_lower(privs, 1)..array_upper(privs, 1) LOOP  
  	IF acl ~ ( user || ''=[rwadRxt]*'' || privs[i]) /* user */
  	THEN
    	RETURN true;
  	END IF;
  END LOOP;

  RETURN false;
END;
' LANGUAGE 'plpgsql';
COMMENT ON FUNCTION check_user_perms ( name, name, name, char[] ) IS 'check_user_perms ( <user::name>, <schema::name>, <table::name>, <char[]> ) returns true if the user has any of the permissions listed in the char[] array';
