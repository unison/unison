create or replace function unison.palias_OAD_fmt(integer)
returns text language plpgsql as '
DECLARE
	a_id alias for $1;
	rv text;
BEGIN
	if a_id is null then
		return a_id;
	end if;

	select into rv 
		O.origin || '':'' || A.alias || '' ('' || A.descr || '')'' 
		from paliasorigin A
		join porigin O on O.porigin_id=A.porigin_id
		where A.palias_id=a_id;
	return rv;
END;';


create or replace function unison.palias_OA_fmt(integer)
returns text language plpgsql as '
DECLARE
	a_id alias for $1;
	rv text;
BEGIN
	if a_id is null then return; end if;
	select into rv 
		O.origin || '':'' || A.alias
		from paliasorigin A
		join porigin O on O.porigin_id=A.porigin_id
		where A.palias_id=a_id;
	return rv;
END;';


create or replace function unison.best_palias_id(integer) 
returns integer language plpgsql as '
DECLARE
	q_id alias for $1;
	a_id integer;
	o_id integer;
	rv text;
BEGIN
	select into a_id palias_id from pseq where pseq_id=q_id;
	if a_id is not null then
		return a_id;
	end if;

	select into a_id QA.palias_id from pseqalias QA
		join paliasorigin OA on OA.palias_id=QA.palias_id
		join porigin O on O.porigin_id=OA.porigin_id
		where QA.pseq_id=q_id and QA.iscurrent=TRUE and O.ann_pref is not null
		order by O.ann_pref limit 1;
	if a_id is not null then
		return a_id;
	end if;

	return NULL;
END;';


create or replace function unison.best_OA(integer) 
returns text language plpgsql as
'BEGIN return palias_OA_fmt( best_palias_id( $1 ) ); END;';

create or replace function unison.best_OAD(integer) 
returns text language plpgsql as
'BEGIN return palias_OAD_fmt( best_palias_id( $1 ) ); END;';

create or replace function unison.best_alias(integer) 
returns text language plpgsql as 'BEGIN	return best_OA( $1 ); END;';

create or replace function unison.best_annotation(integer) 
returns text language plpgsql as 'BEGIN	return best_OAD( $1 ); END;';



comment on function unison.best_palias_id(integer)  is '"best" palias_id of given pseq_id; see best_* functions';
comment on function unison.best_OA(integer)		    is '"best" <origin:alias> for pseq_id';
comment on function unison.best_OAD(integer)	    is '"best" <origin:alias (description)> for pseq_id';
comment on function unison.best_alias(integer)      is 'same as best_OA';
comment on function unison.best_annotation(integer) is 'same as best_OAD';
comment on function unison.palias_OAD_fmt(integer)  is 'cannonical annotation format of given palias_id, like this: <origin>:<alias> (<description>)';
comment on function unison.palias_OA_fmt(integer)   is 'cannonical alias format of given palias_id, like this: <origin>:<alias>';
