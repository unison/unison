drop table run_history;

create table run_history (
	pseq_id integer  not null
		constraint pseq_id_exists references pseq(pseq_id) on delete cascade on update cascade,
	params_id integer not null
		constraint params_id_exists check (params_id_exists(params_id)),
	pmodelset_id integer
		constraint pmodelset_id_exists  check (pmodelset_id_exists(pmodelset_id)),
	ran_on timestamp default now()
) without oids;

create unique index run_history_search1 on run_history (pseq_id,params_id,pmodelset_id);


-- update_run_history updates "run_history.ts" for the given
-- (pseq_id,params_id,pmodelset_id).  If that tuple doesn't exist, it's
-- added.  Either way, the new timestamp is returned.
create or replace function upd_run_history(integer,integer,integer)
returns timestamp
language plpgsql
as '
DECLARE
	q alias for $1;
	r alias for $2;
	m alias for $3;
	z timestamp;
BEGIN
	z:=now();
	if m is null then
		update run_history set ts=z where pseq_id=q and params_id=r and pmodelset_id is null;
	else
		update run_history set ts=z where pseq_id=q and params_id=r and pmodelset_id=m;
	end if;
	if not FOUND then
		-- update failed... tuple must not exist
		insert into run_history (pseq_id,params_id,pmodelset_id,ts) values (q,r,m,z);
	end if;
	return z;
END;';
