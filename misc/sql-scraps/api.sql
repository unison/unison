\echo =======================================================================
\echo $Id$
-- functions to facilitate unison access


/*	si_* : select/insert functions
	These functions are used to quickly /s/elect oft-used values for
	corresponding keys, /i/nserting the key if necessary.

	For the moment, there's no 'does x exist?' functionality.
*/


-- =========================================================================
create or replace function si_porigin_id (text)
returns integer as '
DECLARE
	O alias for $1;				-- origin
	rv integer;
BEGIN
	select into rv porigin_id from porigin where origin = upper(O);
	if found then return rv; end if;
	insert into porigin (origin) values (O);
	select into rv porigin_id from porigin where origin = O;
	return rv;
END;'
language 'plpgsql';
comment on function si_porigin_id (text) is
	 'select/insert a porigin_id from origin text, returns porigin_id';


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


-- =========================================================================
create or replace function add_soa (text,text,text)
returns integer as '
DECLARE
	S alias for $1;				-- sequence
	O alias for $2;				-- origin
	A alias for $3;				-- alias
	si	integer;				-- pseq_id
	oi	integer;				-- porigin_id
BEGIN
	si := si_pseq_id(S);
	oi := si_porigin_id(O);
	insert into palias (pseq_id,porigin_id,alias) values (si,oi,A);
	return si;
END;'
language 'plpgsql';
comment on function add_soa (text,text,text) is
	'add <sequnce,origin,alias> tuple, using existing ids when available, returns pseq_id';



-- =========================================================================
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
