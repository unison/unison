-- -----------------------------------------------------------------------------
-- NAME: best_annotation.sql
-- PURPOSE: set of functions for retrieving the best alias of a given sequence
--
-- $Id$
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- NAME: palias_OAD_fmt(integer)
-- PURPOSE: returns text string of origin, alias, and descr for a given palias_id
-- ARGUMENTS: palias_id
-- RETURNS: text 
--
create or replace function unison.palias_OAD_fmt(integer)
returns text language plpgsql as '
DECLARE
	a_id alias for $1;
	rv text;
	rec record;
BEGIN
	if a_id is null then
		return null;
	end if;

	select into rv O.origin || '':'' || A.alias || '' ('' || coalesce(A.descr, ''No descr available'') || '')''
		from paliasorigin A
		join porigin O on O.porigin_id=A.porigin_id
		where A.palias_id=a_id;

	return rv;
END;';
-- -----------------------------------------------------------------------------
comment on function unison.palias_OAD_fmt(integer)  is 'cannonical annotation format of given palias_id, like this: <origin>:<alias> (<description>)';


-- -----------------------------------------------------------------------------
-- NAME: palias_OA_fmt(integer)
-- PURPOSE: returns text string of origin and alias for a given palias_id
-- ARGUMENTS: palias_id
-- RETURNS: text 
--
create or replace function unison.palias_OA_fmt(integer)
returns text language plpgsql as '
DECLARE
	a_id alias for $1;
	rv text;
BEGIN
	if a_id is null then
		return null;
	end if;
	select into rv 
		O.origin || '':'' || A.alias
		from paliasorigin A
		join porigin O on O.porigin_id=A.porigin_id
		where A.palias_id=a_id;
	return rv;
END;';
-- -----------------------------------------------------------------------------
comment on function unison.palias_OA_fmt(integer)   is 'cannonical alias format of given palias_id, like this: <origin>:<alias>';


-- -----------------------------------------------------------------------------
-- NAME: best_palias_id(integer,boolean)
-- PURPOSE: return the palias_id of the best annotation (highest ann_pref value)
-- ARGUMENTS: pseq_id, flag for whether to allow null ann_pref         
-- RETURNS: text
--
create or replace function unison.best_palias_id(integer,boolean) 
returns integer language plpgsql as '
DECLARE
	q_id alias for $1;
  flag alias for $2;
	a_id integer;
	o_id integer;
	rv text;
BEGIN
	select into a_id palias_id from pseq where pseq_id=q_id;
	if a_id is not null then
		return a_id;
	end if;

	-- allow null ann_pref
	if flag then
		select into a_id QA.palias_id from pseqalias QA
			join paliasorigin OA on OA.palias_id=QA.palias_id
			join porigin O on O.porigin_id=OA.porigin_id
			where QA.pseq_id=q_id and QA.iscurrent=TRUE 
			order by O.ann_pref limit 1;
	-- dont allow null ann_pref
	else
		select into a_id QA.palias_id from pseqalias QA
			join paliasorigin OA on OA.palias_id=QA.palias_id
			join porigin O on O.porigin_id=OA.porigin_id
			where QA.pseq_id=q_id and QA.iscurrent=TRUE and O.ann_pref is not null
			order by O.ann_pref limit 1;
	end if;

	if a_id is not null then
		return a_id;
	end if;

	return NULL;
END;';
-- -----------------------------------------------------------------------------
comment on function unison.best_palias_id(integer,boolean)  is '"best" palias_id of given pseq_id; flag for null ann_pref; see best_* functions';


-- -----------------------------------------------------------------------------
-- NAME: best_palias_id(integer)
-- PURPOSE: backwardly form of best_palias_id(integer,boolean) use false for boolean
-- ARGUMENTS: pseq_id
-- RETURNS: text
--
create or replace function unison.best_palias_id(integer) 
returns integer language plpgsql as 
'BEGIN return best_palias_id($1,false); END;';
-- -----------------------------------------------------------------------------
comment on function unison.best_palias_id(integer)  is 'alias for best_palias_id(integer,false)';


-- -----------------------------------------------------------------------------
-- NAME: best_OA(integer,boolean)
-- PURPOSE: return best origin and alias for a given pseq_id, use boolean
--          to allow inclusion of null ann_pref origins
-- ARGUMENTS: pseq_id, boolean flag for including origins with null ann_pref
-- RETURNS: text
--
create or replace function unison.best_OA(integer,boolean) 
returns text language plpgsql as
'BEGIN return palias_OA_fmt( best_palias_id( $1, $2 ) ); END;';
-- -----------------------------------------------------------------------------
comment on function unison.best_OA(integer,boolean) is '"best" <origin:alias> for pseq_id';


-- -----------------------------------------------------------------------------
-- NAME: best_OA(integer)
-- PURPOSE: backwardly form of best_OA(integer,boolean) use false for boolean
-- ARGUMENTS: pseq_id
-- RETURNS: text
--
create or replace function unison.best_OA(integer) 
returns text language plpgsql as
'BEGIN return best_OA( $1, false ); END;';
-- -----------------------------------------------------------------------------
comment on function unison.best_OA(integer) is 'alias for best_OA(integer,false)';


-- -----------------------------------------------------------------------------
-- NAME: best_OAD(integer,boolean)
-- PURPOSE: return best origin, alias and descr for a given pseq_id, use boolean
--          to allow inclusion of null ann_pref origins
-- ARGUMENTS: pseq_id, boolean flag for including origins with null ann_pref
-- RETURNS: text
--
create or replace function unison.best_OAD(integer,boolean) 
returns text language plpgsql as
'BEGIN return palias_OAD_fmt( best_palias_id( $1, $2 ) ); END;';
comment on function unison.best_OAD(integer,boolean) is '"best" <origin:alias (description)> for pseq_id';
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- NAME: best_OAD(integer)
-- PURPOSE: alias for best_OAD(integer,false)
-- ARGUMENTS: pseq_id
-- RETURNS: text
--
create or replace function unison.best_OAD(integer) 
returns text language plpgsql as
'BEGIN return best_OAD( $1, false ); END;';
comment on function unison.best_OAD(integer) is 'alias for best_OAD(integer,false)';
-- -----------------------------------------------------------------------------


-- -----------------------------------------------------------------------------
-- NAME: best_alias(integer,boolean)
-- PURPOSE: alias for best_OA(integer,boolean)
-- ARGUMENTS: pseq_id, boolean flag for including origins with null ann_pref
-- RETURNS: text
--
create or replace function unison.best_alias(integer,boolean) 
returns text language plpgsql as 'BEGIN	return best_OA( $1, $2 ); END;';
-- -----------------------------------------------------------------------------
comment on function unison.best_alias(integer,boolean) is 'same as best_OA';


-- -----------------------------------------------------------------------------
-- NAME: best_alias(integer)
-- PURPOSE: alias for best_alias(integer,false)
-- ARGUMENTS: pseq_id
-- RETURNS: text
--
create or replace function unison.best_alias(integer) 
returns text language plpgsql as 'BEGIN	return best_alias( $1, false ); END;';
-- -----------------------------------------------------------------------------
comment on function unison.best_alias(integer) is 'alias for best_alias(integer,false)';


-- -----------------------------------------------------------------------------
-- NAME: best_annotation(integer,boolean)
-- PURPOSE: alias for best_OAD(integer,boolean)
-- ARGUMENTS: pseq_id, boolean flag for including origins with null ann_pref
-- RETURNS: text
--
create or replace function unison.best_annotation(integer,boolean) 
returns text language plpgsql as 'BEGIN	return best_OAD( $1, $2 ); END;';
comment on function unison.best_annotation(integer,boolean) is 'same as best_OAD';


-- -----------------------------------------------------------------------------
-- NAME: best_annotation(integer)
-- PURPOSE: alias for best_annotation(integer,false)
-- ARGUMENTS: pseq_id
-- RETURNS: text
--
create or replace function unison.best_annotation(integer) 
returns text language plpgsql as 'BEGIN	return best_annotation( $1, false ); END;';
comment on function unison.best_annotation(integer) is 'alias for best_annotation(integer,false)';
