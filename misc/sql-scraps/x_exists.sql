create or replace function params_id_exists (integer)
returns boolean
strict immutable
language plpgsql as '
BEGIN
	perform * from params where params_id=$1;
	if found then return TRUE; end if;
	return FALSE;
END;
';


create or replace function pmodel_id_exists (integer)
returns boolean
strict immutable
language plpgsql as '
BEGIN
	perform * from pmodel where pmodel_id=$1;
	if found then return TRUE; end if;
	return FALSE;
END;
';


create or replace function pmodelset_id_exists (integer)
returns boolean
strict immutable
language plpgsql as '
BEGIN
	perform * from pmodelset where pmodelset_id=$1;
	if found then return TRUE; end if;
	return FALSE;
END;
';
