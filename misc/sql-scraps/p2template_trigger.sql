create or replace function p2template_iu_trigger ()
returns TRIGGER
language plpgsql as '
BEGIN
	if new.origin_id is NULL then
		new.origin_id = origin_id_lookup(''Prospect2'');
	end if;
	return new;
END;';
