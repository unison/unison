create or replace function init_db()
returns void
language plpgsql
as
$_$
DECLARE
	v_db text;
	cmd text;
BEGIN
	SELECT INTO v_db current_database();

	SELECT INTO cmd 'ALTER DATABASE "' || v_db || '" SET search_path="$user", unison, pdb, gong, scop, tax, public';
	RAISE NOTICE '%', cmd;
	EXECUTE cmd;

	SELECT INTO cmd 'ALTER DATABASE "' || v_db || '" SET statement_timeout=1800000';
	RAISE NOTICE '%', cmd;
	EXECUTE cmd;
END;
$_$;
