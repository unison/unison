create or replace function unison.best_annotation(integer) 
returns text language plpgsql as '
DECLARE
	q_id alias for $1;
	a_id integer;
	o_id integer;
	rv text;
BEGIN
	select into a_id palias_id from pseq where pseq_id=q_id;
	if a_id is not null then
		return ''*'' || cannonical_alias_fmt( a_id );
	end if;

	select into a_id QA.palias_id from pseqalias QA
		join paliasorigin OA on OA.palias_id=QA.palias_id
		join porigin O on O.porigin_id=OA.porigin_id
		where QA.pseq_id=q_id and QA.iscurrent=TRUE and O.ann_pref is not null
		order by O.ann_pref limit 1;
	if a_id is not null then
		return cannonical_alias_fmt( a_id );
	end if;

	return NULL;
	--return ''<no annotation>'';
END;';


create or replace function unison.cannonical_alias_fmt(integer)
returns text language plpgsql as '
DECLARE
	a_id alias for $1;
	rv text;
BEGIN
	select into rv 
		O.origin || '':'' || A.alias || '' ('' || A.descr || '')'' 
		from paliasorigin A
		join porigin O on O.porigin_id=A.porigin_id
		where A.palias_id=a_id;
	return rv;
END;';
