create or replace function upd_run_history(integer,integer,integer)
returns timestamp
language plpgsql
as '
BEGIN
	raise warning ''upd_run_history(integer,integer,integer) is deprecated'';
	raise warning ''  use upd_run_history(integer,integer,NULL,integer) instead.'';
	return upd_run_history($1,$2,NULL,$3);
END;';

comment on function upd_run_history(integer,integer,integer) is 'deprecated; see upd_run_history(integer,integer,integer,integer)';
