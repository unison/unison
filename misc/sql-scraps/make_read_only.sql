-- WARNING: make_schema_tables_read_only(text) revokes all insert, update,
-- delete permissions from tables in the specified schema. Use it with
-- care.

create or replace function make_schema_tables_read_only(text)
returns void
language plpgsql as '
DECLARE
	ns alias for $1;
	ns_oid oid;
	rel text;
	cmd text;
BEGIN
	SELECT INTO ns_oid oid FROM pg_namespace WHERE nsname=ns;

	FOR rel IN SELECT relname FROM pg_class WHERE relnamespace=ns_oid AND
		relkind in (''r'',''v'');

	cmd = ''REVOKE INSERT,UPDATE,DELETE on "''||ns||''.''||rel||''" FROM *