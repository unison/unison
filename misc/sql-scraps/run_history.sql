create or replace function upd_run_history(integer,integer,boolean)
returns timestamp with time zone
language plpgsql
as '
DECLARE
	q alias for $1;
	r alias for $2;
	f alias for $3;
	z timestamp;
BEGIN
	z:=now();
	update run_history set failed=f,ran_on=z where pseq_id=q and run_id=r;
	if not FOUND then
		-- update failed... tuple must not exist
		insert into run_history (pseq_id,run_id,failed,ran_on) values (q,r,f,z);
	end if;
	return z;
END;';

comment on function upd_run_history(integer,integer,boolean) is 'inserts/updates run_history for the given pseq_id,run_id,failed); returns timestamp';


create or replace function upd_run_history(integer,integer)
returns timestamp with time zone language plpgsql as 'BEGIN return upd_run_history($1,$2,NULL); END';
comment on function upd_run_history(integer,integer) is 'equivalent to upd_run_history(pseq_id,run_id,NULL)';
