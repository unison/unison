create or replace function unison.release() returns void
language plpgsql as '
BEGIN
--	perform p2thread_create_indices();
	
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
	ts timestamp;
BEGIN
	ts:=now(); raise notice ''meta_stats_update: started %'',ts;

	-- sequence stats
--	select into n count(*) from pseq;
--	perform meta_update_kv(''unique sequences'',n);
--	select into n count(*) from pseq where added>=now()-''30 days''::interval;
--	perform meta_update_kv(''new sequences in last 30 days'',n);
--	select into n count(*) from pseq where added>=now()-''60 days''::interval;
--	perform meta_update_kv(''new sequences in last 60 days'',n);
--	select into n count(*) from pseq where added>=now()-''180 days''::interval;
--	perform meta_update_kv(''new sequences in last 180 days'',n);
--
--	-- alias and origin stats
--	select into n count(*) from palias;
--	perform meta_update_kv(''aliases'',n);
--	select into n count(distinct tax_id) from palias;
--	perform meta_update_kv(''species'',n);

	-- number of distinct sequences in an origin and 
	-- number of distinct sequences unique to an origin
	FOR r IN select porigin_id,origin from porigin where ann_pref is not null LOOP
		create temp table in_r as select distinct pseq_id from palias
			where porigin_id=r.porigin_id limit 10000;
		select into n count(*) from in_r;
		perform meta_update_kv(''distinct sequences in ''||r.origin ,n);

		create temp table not_in_r as select pseq_id from in_r
			except select pseq_id from palias where porigin_id!=r.porigin_id limit 1000;
		select into n count(*) from not_in_r;
		-- this is faster (I think):
--		select into n count(distinct pseq_id) from palias a1 where a1.porigin_id=r.porigin_id
-- 			and	not exists (select * from palias a2 where a2.pseq_id=a1.pseq_id and a2.porigin_id!=a1.porigin_id);
--		perform meta_update_kv(''distinct sequences unique to ''||r.origin ,n);

		drop table in_r;
		drop table not_in_r;
	END LOOP;

	-- pfeatures
	select into n count(*) from pfeature;
	perform meta_update_kv(''protein features'',n);

	-- prospect features
	drop table counts;
	create temp table counts as select pseq_id,count(pfeature_id) from paprospect2 where run_id=1 group by pseq_id;
	select into n sum(count) from counts;
	perform meta_update_kv(''threading alignments'',n);
	select into n count(distinct pseq_id) from counts;
	perform meta_update_kv(''threaded sequences'',n);
	select count(pseq_id) from counts where count!=(select max(count) from counts);
	perform meta_update_kv(''incompletely threaded sequences'',n);

	-- hmm features
	drop table counts;
	create temp table counts as select pseq_id,count(pfeature_id) from pahmm group by pseq_id;
	select into n sum(count) from counts;
	perform meta_update_kv(''HMM alignments'',n);
	select into n count(distinct pseq_id) from counts;
	perform meta_update_kv(''HMM-aligned sequences'',n);

	-- pssm features
	drop table counts;
	create temp table counts as select pseq_id,count(pfeature_id) from papssm group by pseq_id;
	select into n sum(count) from counts;
	perform meta_update_kv(''PSSM alignments'',n);
	select into n count(distinct pseq_id) from counts;
	perform meta_update_kv(''PSSM-aligned sequences'',n);

	-- papseq features
	drop table counts;
	create temp table counts as select pseq_id,count(pfeature_id) from papseq group by pseq_id;
	select into n sum(count) from counts;
	perform meta_update_kv(''BLAST alignments'',n);
	select into n count(distinct pseq_id) from counts;
	perform meta_update_kv(''BLAST-aligned sequences'',n);

	perform meta_update_kv(''stats timestamp'',now());

	ts:=now(); raise notice ''meta_stats_update: finished %'',ts;

	return;
END;';
comment on function meta_stats_update() is 'update database statistics in meta';


create or replace function meta_update_kv(text,text) returns void
language plpgsql as '
BEGIN
	delete from meta where key=$1;
	insert into meta (key,value) values ($1,$2);
	raise notice ''meta_update_kv: % = %'',$1,$2;
	return;
END;';
comment on function meta_update_kv(text,text) is 'replacement insert into meta table';
