create or replace function p2template_iu_trigger ()
returns TRIGGER
language plpgsql as '
BEGIN
	if new.porigin_id is NULL then
		new.porigin_id = porigin_id_lookup(''Prospect2'');
	end if;
	return new;
END;';
