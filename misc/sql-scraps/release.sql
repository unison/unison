create or replace function unison.release() returns NULL
language plpgsql as '
BEGIN
	perform p2thread_create_indices();
	
	delete from meta;
	perform meta_stats_update();
	perform meta_update_kv(''release timestamp'',now());

	return;
END;';
comment on function release() is 'prepare database for release';


create or replace function meta_stats_update() returns void
language plpgsql as '
DECLARE
	n integer;
	r record;
BEGIN
	select into n count(*) from pseq;
	perform meta_update_kv(''number of unique sequences'',n);

	select into n count(*) from palias;
	perform meta_update_kv(''number of aliases'',n);

	perform meta_stats_distinct();
	perform meta_stats_unique();

	select into n count(*) from pfeature;
	perform meta_update_kv(''number of protein features'',n);

	select into n count(*) from p2thread;
	perform meta_update_kv(''number of threading results'',n);

	select into n count(distinct pseq_id) from p2thread;
	perform meta_update_kv(''number of threaded sequences'',n);

	perform meta_update_kv(''stats timestamp'',now());
	return;
END;';
comment on function meta_stats_update() is 'update database statistics in meta';


create or replace function meta_stats_distinct() returns void
language plpgsql as '
DECLARE
	n integer;
	r record;
BEGIN
	FOR r IN select porigin_id,origin from porigin LOOP
		select into n count(distinct pseq_id) from palias where porigin_id=r.porigin_id;
		perform meta_update_kv(''number of distinct sequences in ''||r.origin ,n);
	END LOOP;
	return;
END;';
comment on function meta_stats_distinct() is 'count number of distinct sequences in an origin';


create or replace function meta_stats_unique() returns void
language plpgsql as '
DECLARE
	n integer;
	r record;
BEGIN
	FOR r IN select porigin_id,origin from porigin LOOP
		select into n count(distinct pseq_id) from palias a1 where a1.porigin_id=r.porigin_id 
			and	not exists (select * from palias a2 where a2.pseq_id=a1.pseq_id and a2.porigin_id!=a1.porigin_id);
		perform meta_update_kv(''number of sequences unique to ''||r.origin ,n);
	END LOOP;
	return;
END;';
comment on function meta_stats_distinct() is 'count number of sequences unique to an origin';


create or replace function meta_update_kv(text,text) returns void
language plpgsql as '
BEGIN
	delete from meta where key=$1;
	insert into meta (key,value) values ($1,$2);
	raise notice ''meta_update_kv: % = %'',$1,$2;
	return;
END;';
comment on function meta_update_kv(text,text) is 'replacement insert into meta table';
