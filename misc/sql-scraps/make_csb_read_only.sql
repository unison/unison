/*
 * make_csb_read_only()
 * return false if current database is not csb
 * run make_schema_read_only for each schema in the csb database
 * return true if make_schema_read_only is succesful for all schemas
 * $ID = q$Id$;
 */
create or replace function unison.make_csb_read_only()
returns bool as '
declare
	schemas name[] := ''{unison,scop,gong,tax}'';
	dbname name;
	i integer := 0;
	n integer := 0;
	ret bool := false;
begin
	select into dbname current_database();

	IF dbname != ''csb'' THEN
	RAISE EXCEPTION ''This operation is restricted for the CSB database'';
	END IF;

	FOR i IN array_lower(schemas, 1)..array_upper(schemas, 1) LOOP	
		select into ret make_schema_read_only(schemas[i]);

		IF ret = true THEN
		n := n + 1;
		END IF;

	END LOOP;

	IF n = array_upper(schemas, 1) THEN
	return true;
	END IF;

return false;
end;'
language 'plpgsql';

COMMENT ON FUNCTION make_csb_read_only() IS 'make_csb_read_only() runs make_schema_read_only for each schema in the current database and returns true if make_schema_read_only is successful for all schemas';
