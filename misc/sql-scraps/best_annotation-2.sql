-- $Id: best_annotation.sql,v 1.7 2003/09/30 22:50:02 cavs Exp $

-- NOTE: the sort by strpos(alias,...) bits below guarantee that
-- Swiss-Prot/UniProt ids (TNFA_HUMAN) sort before the accessions
-- (P01234), which have the same ann_pref.


create or replace view unison.v_all_annotations as 
SELECT sa.pseq_id, sa.iscurrent, o.ann_pref,ao.porigin_id, o.origin, ao.tax_id, t.gs,
ao.alias, ao.descr, ao.palias_id, sa.added as assigned
FROM paliasorigin ao
JOIN pseqalias sa ON ao.palias_id = sa.palias_id
JOIN porigin o ON o.porigin_id=ao.porigin_id
LEFT JOIN spspec t on ao.tax_id=t.tax_id
ORDER BY sa.pseq_id, sa.iscurrent DESC, o.ann_pref, strpos(alias, '_'::text) = 0, ao.alias;
comment on view v_all_annotations is 'all annotations by pseq_id';
grant select on v_all_annotations to PUBLIC;                                                                                                                                                                                                                                                                                                                                                                                                                                                            


create or replace view
v_current_annotations as select * from v_all_annotations where
iscurrent=true ORDER BY pseq_id, ann_pref, strpos(alias, '_'::text) = 0,
alias;
grant select on v_current_annotations to PUBLIC;                                                                                                                                                                                                                                                                                                                                                                                                                                                            
comment on view v_current_annotations is 'all current annotations by pseq_id';


create or replace view
v_best_annotation as select distinct on (pseq_id) * from
v_all_annotations ORDER BY pseq_id, iscurrent DESC, ann_pref,
strpos(alias, '_'::text) = 0, alias;
comment on view v_best_annotation is
   '"best" single annotation based on origin reliability (origin.ann_pref)';
grant select on v_best_annotation to PUBLIC;



create or replace function origin_alias_fmt(text,text) returns text immutable 
language plpgsql as '
BEGIN
	return $1 || '':'' || $2;
END;';

create or replace function origin_alias_descr_fmt(text,text,text) returns text immutable 
language plpgsql as '
BEGIN
	return origin_alias_fmt($1,$2) || '' ('' || coalesce($3, ''No description available'') || '')'';
END;';


create or replace function best_alias(integer) returns text immutable strict language sql as 
'select origin_alias_fmt(origin,alias) from v_best_annotation where pseq_id=$1;';

create or replace function best_annotation(integer) returns text immutable strict language sql as 
'select origin_alias_descr_fmt(origin,alias,descr) from v_best_annotation where pseq_id=$1;';

create or replace function best_palias_id(integer)  returns integer immutable strict language sql as 
'select palias_id from v_best_annotation where pseq_id=$1;';






-- DEPRECATED FUNCTIONS
create or replace function best_alias(integer,boolean) returns text
language plpgsql strict immutable as '
BEGIN
	perform warn(''best_alias(integer,boolean) is deprecated; use best_alias(integer) instead.'');
	return best_alias($1);
END;
';

create or replace function best_annotation(integer,boolean) returns text
language plpgsql strict immutable as '
BEGIN
	perform warn(''best_annotation(integer,boolean) is deprecated; use best_annotation(integer) instead.'');
	return best_annotation($1);
END;
';

create or replace function best_palias_id(integer,boolean) returns integer
language plpgsql strict immutable as '
BEGIN
	perform warn(''best_palias_id(integer,boolean) is deprecated; use best_palias_id(integer) instead.'');
	return best_palias_id($1);
END;
';

