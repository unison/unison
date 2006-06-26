create or replace function sst_palias_id(integer)
returns integer
strict stable
language plpgsql as '
BEGIN
	raise warning ''SST_PALIAS_ID is deprecated'';
	raise warning ''  use SPDI_PALIAS_ID instead'';
	return( spdi_palias_id( $1 ) );	
END;';


create or replace function spdi_palias_id(integer)
returns integer 
strict stable
language plpgsql as '
DECLARE
	q_id alias for $1;
	a_id integer;
BEGIN
	-- order by alias desc has the effect of preferring UNQ, then PRO, then DNA
	select into a_id QA.palias_id from pseqalias QA
		join paliasorigin OA on OA.palias_id=QA.palias_id
		where QA.pseq_id=q_id and QA.iscurrent=TRUE and OA.origin_id=origin_id(''SPDI'')
		order by alias desc
		limit 1;
	return a_id;
END;';

create or replace function spdi_UNQ_palias_id(integer)
returns integer 
strict stable
language plpgsql as '
DECLARE
	q_id alias for $1;
	a_id integer;
BEGIN
	select into a_id QA.palias_id from pseqalias QA
		join paliasorigin OA on OA.palias_id=QA.palias_id
		where QA.pseq_id=q_id and QA.iscurrent=TRUE and OA.origin_id=origin_id(''SPDI'') and alias~''^UNQ''
		limit 1;
	return a_id;
END;';

create or replace function spdi_PRO_palias_id(integer)
returns integer 
strict stable
language plpgsql as '
DECLARE
	q_id alias for $1;
	a_id integer;
BEGIN
	select into a_id QA.palias_id from pseqalias QA
		join paliasorigin OA on OA.palias_id=QA.palias_id
		where QA.pseq_id=q_id and QA.iscurrent=TRUE and OA.origin_id=origin_id(''SPDI'') and alias~''^PRO''
		limit 1;
	return a_id;
END;';

create or replace function spdi_DNA_palias_id(integer)
returns integer 
strict stable
language plpgsql as '
DECLARE
	q_id alias for $1;
	a_id integer;
BEGIN
	select into a_id QA.palias_id from pseqalias QA
		join paliasorigin OA on OA.palias_id=QA.palias_id
		where QA.pseq_id=q_id and QA.iscurrent=TRUE and OA.origin_id=origin_id(''SPDI'') and alias~''^DNA''
		limit 1;
	return a_id;
END;';
