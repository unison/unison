create or replace function porigin_id_lookup (text)
returns integer
language plpgsql as '
DECLARE
	rv integer;
BEGIN
	select into rv porigin_id from porigin where origin = $1;
	return rv;
END;';
