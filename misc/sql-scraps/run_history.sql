drop table run_history;

create table run_history (
	pseq_id integer  not null
		constraint pseq_id_exists references pseq(pseq_id) on delete cascade on update cascade,
	params_id integer not null
		constraint params_id_exists check (params_id_exists(params_id)),
	porigin_id integer
		constraint porigin_id_exists  check (porigin_id_exists(porigin_id)),
	pmodelset_id integer
		constraint pmodelset_id_exists  check (pmodelset_id_exists(pmodelset_id)),
	ran_on timestamp default now()
) without oids;

create unique index run_history_search on run_history (pseq_id,params_id)
	where porigin_id is null and pmodelset_id is null;
create unique index run_history_search_o on run_history (pseq_id,params_id,porigin_id)
	where porigin_id is not null and pmodelset_id is null;
create unique index run_history_search_m on run_history (pseq_id,params_id,pmodelset_id)
	where porigin_id is null and pmodelset_id is not null;
create unique index run_history_search_om on run_history (pseq_id,params_id,porigin_id,pmodelset_id)
	where porigin_id is not null and pmodelset_id is not null;

comment on table run_history is 'history of runs analyses for a given sequence';


-- update_run_history updates "run_history.ts" for the given
-- (pseq_id,params_id,pmodelset_id).  If that tuple doesn't exist, it's
-- added.  Either way, the new timestamp is returned.
create or replace function upd_run_history(integer,integer,integer,integer)
returns timestamp
language plpgsql
as '
DECLARE
	q alias for $1;
	p alias for $2;
	o alias for $3;
	m alias for $4;
	z timestamp;
BEGIN
	z:=now();
	update run_history set ran_on=z where pseq_id=q and params_id=p 
		and (case when o is null then porigin_id is null else porigin_id=o end)
		and (case when m is null then pmodelset_id is null else pmodelset_id=m end);
	if not FOUND then
		-- update failed... tuple must not exist
		insert into run_history (pseq_id,params_id,porigin_id,pmodelset_id,ran_on) values (q,p,o,m,z);
	end if;
	return z;
END;';

comment on table run_history is 'updates run_history for the given pseq_id,params_id,porigin_id,pmodelset_id); returns timestamp';




create or replace function get_run_timestamp(integer,integer,integer,integer)
returns timestamp with time zone
language plpgsql
as '
DECLARE
    q alias for $1;
    p alias for $2;
    o alias for $3;
    m alias for $4;
    z timestamp;
BEGIN
    select into z ran_on from run_history
        where pseq_id=q
        and params_id=p
        and (case when o is null then porigin_id is NULL else porigin_id=o end)
        and (case when m is null then pmodelset_id is NULL else pmodelset_id=m end);
    return z;
END;';
