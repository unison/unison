create or replace function params_id_exists (integer)
returns boolean
strict immutable
language plpgsql as '
BEGIN
	perform * from params where params_id=$1;
	return FOUND;
END;
';
comment on function params_id_exists(integer) is 'return true if params_id exists';


create or replace function porigin_id_exists (integer)
returns boolean
strict immutable
language plpgsql as '
BEGIN
	perform * from porigin where porigin_id=$1;
	return FOUND;
END;
';
comment on function porigin_id_exists(integer) is 'return true if porigin_id exists';


create or replace function pmodel_id_exists (integer)
returns boolean
strict immutable
language plpgsql as '
BEGIN
	perform * from pmodel where pmodel_id=$1;
	return FOUND;
END;
';
comment on function pmodel_id_exists(integer) is 'return true if pmodel_id exists pmodel or subclass thereof';


create or replace function pmodelset_id_exists (integer)
returns boolean
strict immutable
language plpgsql as '
BEGIN
	perform * from pmodelset where pmodelset_id=$1;
	return FOUND;
END;
';
comment on function pmodelset_id_exists(integer) is 'return true if pmodelset_id exists';
