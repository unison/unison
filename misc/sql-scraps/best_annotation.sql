create or replace function unison.best_annotation(integer) 
returns text language plpgsql as '
DECLARE
	q_id alias for $1;
	a_id integer;
	o_id integer;
	rv text;
BEGIN
	select into a_id palias_id from pseq where pseq_id=q_id;

	if a_id is null then
	select into a_id QA.palias_id from pseqalias QA
		join paliasorigin OA on OA.palias_id=QA.palias_id
		join porigin O on O.porigin_id=OA.porigin_id
		where QA.pseq_id=q_id and QA.iscurrent=TRUE and O.ann_pref is not null
		order by O.ann_pref limit 1;
	end if;
	
	if a_id is not null then
		select into rv 
			O.origin || '':'' || A.alias || '' ('' || A.descr || '')'' 
			from paliasorigin A
			join porigin O on O.porigin_id=A.porigin_id
			where A.palias_id=a_id;
	end if;

	return rv;
END;';


create or replace function unison.best_annotation_1(integer,integer)
returns text language plpgsql as '
DECLARE
	q_id alias for $1;
	o_id alias for $2;
	a_id integer;
BEGIN
	select into a_id QA.palias_id from pseqalias QA
		join paliasorigin AO on AO.palias_id=QA.palias_id
		where QA.pseq_id=q_id and QA.iscurrent=TRUE and AO.porigin_id=o_id;
	return a_id;
END;';


create or replace function unison.best_annotation_old(integer) 
returns text language plpgsql as '
DECLARE
	q_id alias for $1;
	a_id integer;
	o_id integer;
	rv text;
BEGIN
	select into a_id palias_id from pseq where pseq_id=q_id;

	if a_id is null then
		select into a_id best_annotation_1(q_id,12); -- swiss-prot
	if a_id is null then
		select into a_id best_annotation_1(q_id,19); -- proteome
	if a_id is null then
		select into a_id best_annotation_1(q_id,20); -- refseq
	if a_id is null then
		select into a_id best_annotation_1(q_id,15); -- spdi
	if a_id is null then
		select into a_id best_annotation_1(q_id,10016); -- sstpro
	if a_id is null then
		select into a_id best_annotation_1(q_id,10005);	-- dblast
	if a_id is null then
		select into a_id best_annotation_1(q_id,10003); -- nr
	if a_id is null then
		select into a_id best_annotation_1(q_id,11); -- pdb
	end if;	end if;	end if;	end if;	end if;	end if;	end if;	end if;
	
	if a_id is not null then
		select into rv 
			O.origin || '':'' || A.alias || '' ('' || A.descr || '')'' 
			from paliasorigin A
			join porigin O on O.porigin_id=A.porigin_id
			where A.palias_id=a_id;
	end if;

	return rv;
END;';


