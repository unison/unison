create or replace function unison.pseq_species(integer)
returns text
language plpgsql as '
DECLARE
	v_pseq_id alias for $1;
	rv text;
BEGIN
	select into rv
		asset(distinct tax.spspec_name(spspec_id)) from pseqalias
		natural join paliasorigin
		where pseq_id=v_pseq_id and iscurrent=TRUE
		group by pseq_id;
	return rv;
END;';
