/*
 * check_public_perms ( <schema name>, <relation name>, <mode flag array>  );
 * <mode flag array> consists of letters 'w', 'r', 'a', 'd', 'R', 'x' OR 't'
 * $ID = q$Id$;
 */
CREATE OR REPLACE FUNCTION unison.check_public_perms ( name, name, char[] ) RETURNS bool AS '
DECLARE
  schema alias for $1;
  table alias for $2;
  privs alias for $3;
  acl text;
  rec record;
  i integer;
BEGIN
  -- check if the input array has the right permission letters
  FOR i IN array_lower(privs, 1)..array_upper(privs, 1) LOOP  
  IF ( privs[i] NOT IN ( ''w'',''r'',''a'',''d'',''R'',''x'',''t'' ) ) THEN
    RAISE EXCEPTION ''mode flags must use single letter from "arwdRxt"'';
  END IF;
  END LOOP;

  SELECT INTO rec perms 
  FROM v_table_perms WHERE schemaname = schema AND tablename = table;

  IF NOT FOUND THEN
    RAISE EXCEPTION ''Did not find any schema name "%", relation named "%".'', schema, table;
  END IF;

  acl := rec.perms;

  IF acl IS NULL THEN
    RETURN false;
  END IF;

  FOR i IN array_lower(privs, 1)..array_upper(privs, 1) LOOP  
	  IF acl ~ ( ''\,=[rwadRxt]*'' || privs[i] ) /* public */
	  THEN
	    RETURN true;
	  END IF;
  END LOOP;

  RETURN false;
END;
' LANGUAGE 'plpgsql';

COMMENT ON FUNCTION check_public_perms ( name, name, char[] ) IS 'check_public_perms ( <schema::name>, <table::name>, <char[]> ) returns true if public has any of the permissions listed in the char[] array';
