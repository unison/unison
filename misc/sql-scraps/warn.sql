create or replace function warn(text) returns void
language plpgsql as '
DECLARE
	msg text;
BEGIN
	msg:=$1;
	RAISE WARNING ''%'', msg;
	return;
END;';


create or replace function notice(text) returns void
language plpgsql as '
DECLARE
	msg text;
BEGIN
	msg:=$1;
	RAISE notice ''%'', msg;
	return;
END;';

