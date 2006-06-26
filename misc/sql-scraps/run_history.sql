create or replace function upd_run_history(integer,integer,integer,integer,boolean)
returns timestamp with time zone
language plpgsql
as '
DECLARE
	q alias for $1;
	p alias for $2;
	o alias for $3;
	m alias for $4;
	f alias for $5;
	z timestamp;
BEGIN
	z:=now();
	update run_history set failed=f,ran_on=z where pseq_id=q and params_id=p 
		and (case when o is null then origin_id is null else origin_id=o end)
		and (case when m is null then pmodelset_id is null else pmodelset_id=m end);
	if not FOUND then
		-- update failed... tuple must not exist
		insert into run_history (pseq_id,params_id,origin_id,pmodelset_id,failed,ran_on) values (q,p,o,m,f,z);
	end if;
	return z;
END;';

comment on function upd_run_history(integer,integer,integer,integer,boolean) is 'inserts/updates run_history for the given pseq_id,params_id,origin_id,pmodelset_id,failed); returns timestamp';


create or replace function upd_run_history(integer,integer,integer,integer)
returns timestamp with time zone language plpgsql as 'BEGIN return upd_run_history($1,$2,$3,$4,NULL); END';
comment on function upd_run_history(integer,integer,integer,integer) is 'equivalent to upd_run_history(pseq_id,params_id,origin_id,pmodelset_id,NULL)';






