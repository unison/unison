/*
 * make_schema_read_only(<schema_name>)
 * run make_table_read_only for each table in the input schema
 * return true if make_table_read_only is succesful for all tables
 * $ID = q$Id$;
 */
create or replace function unison.make_schema_read_only(name)
returns bool as '
declare
	schema alias for $1;
	table_schema record;
	num_tables integer;
	ret bool;
	n integer := 0;
begin

	select into num_tables COUNT(*) from v_table_perms where schemaname = schema;
	IF num_tables = 0 THEN
	RAISE EXCEPTION ''% tables found in % schema'',num_tables,schema;
	END IF;

	FOR table_schema in select tablename from v_table_perms where schemaname = schema LOOP
		select into ret make_table_read_only(schema,table_schema.tablename);

		IF ret = true THEN
		n := n + 1;
		END IF;

	END LOOP;

	IF n = num_tables THEN
	return true;
	END IF;

return false;
end;'
language 'plpgsql';

COMMENT ON FUNCTION make_schema_read_only(name) IS 'make_schema_read_only(<schema_name>) runs make_table_read_only for each table in the input schema and returns true if make_table_read_only is successful for all tables';
