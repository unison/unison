\echo =======================================================================
\echo $Id$

create or replace function si_p2template_id (text)
returns integer as '
DECLARE
	S text;
	rv integer;
BEGIN
	S := clean_sequence($1);
	select into rv pseq_id from pseq where md5 = md5(S) and len = length(S);
	if found then return rv; end if;
	insert into pseq (seq) values (S);
	select into rv pseq_id from pseq where md5 = md5(S) and len = length(S);
	return rv;
END;'
language 'plpgsql';
comment on function si_pseq_id (text) is
	 'select/insert a pseq_id from sequence, returns pseq_id';


-- =========================================================================
create or replace function si_pseq_id (text)
returns integer as '
DECLARE
	S text;
	rv integer;
BEGIN
	S := clean_sequence($1);
	select into rv pseq_id from pseq where md5 = md5(S) and len = length(S);
	if found then return rv; end if;
	insert into pseq (seq) values (S);
	select into rv pseq_id from pseq where md5 = md5(S) and len = length(S);
	return rv;
END;'
language 'plpgsql';
comment on function si_pseq_id (text) is
	 'select/insert a pseq_id from sequence, returns pseq_id';
