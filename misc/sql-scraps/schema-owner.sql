create or replace function set_schema_owners () returns integer as '
DECLARE
	r RECORD;
	i integer := 0;
BEGIN
	FOR r IN select pg_namespace.oid,* from pg_namespace join pg_user on usename=nspname  where nspowner!=usesysid LOOP
		i = i+1;
		raise notice ''%. namespace % (oid %) was owned by %; reset to %'', 
			i, r.nspname, r.oid, r.nspowner, r.usesysid;
		update pg_namespace set nspowner=r.usesysid where oid=r.oid;
	END LOOP;
	return i;
end;'
language plpgsql;

comment on function set_schema_owners() is 'ensure that all schemas are owned by same-named users where such exists';
