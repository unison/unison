\echo =======================================================================
\echo $Id$


create or replace function get_pstr_id (text)
returns integer as '
DECLARE
	rv integer;
BEGIN
	select into rv pstr_id from pstr where pdbc = upper($1);
	return rv;
END;'
language 'plpgsql';
comment on function get_pstr_id (text) is
	 'return pstr_id for pdbc (pdb + chain)';
