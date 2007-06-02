create or replace function run_all_perftests(in pid integer)
returns void
language plpgsql
as $_$
DECLARE
	pla perftest_platform%ROWTYPE;
	def perftest_def%ROWTYPE;
	res perftest_result%ROWTYPE;
	i smallint;
	t0 timestamp;
	t1 timestamp;
	td integer;
	sum_td integer;
	rows integer;
	rid integer;
BEGIN
	SELECT INTO pla * FROM perftest_platform where platform_id = pid;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'platform_id=%: NOT FOUND; aborting', pid;
	END IF;

	-- sanity checks to ensure that the user doesn't call us with an obviously bogus
	-- platform_id
	IF NOT pla.current THEN
		RAISE EXCEPTION 'platform_id=%: platform is not current; aborting', pid;
	END IF;

	IF pla.locked THEN
		RAISE EXCEPTION 'platform_id=%: platform is locked; aborting', pid;
	END IF;

	IF pla.pg_version_str != version() THEN
		RAISE EXCEPTION 'platform_id=% pg_version_str=% but version()=%; aborting', pid, pla.pg_version_str, version();
	END IF;

	IF pla.ip != inet_server_addr() THEN
		RAISE EXCEPTION 'platform_id=% ip=% but inet_server_addr()=%; aborting', pid, pla_ip, inet_server_addr();
	END IF;

	insert into perftest_run (platform_id,start_ts) values (pid,clock_timestamp()::timestamp);
	rid := lastval();			-- run_id from above insertion

	RAISE NOTICE '* running perftest for platform_id=% (%), run_id %', pid, pla.name, rid;

	FOR def IN SELECT * FROM perftest_def WHERE current ORDER BY ordr,def_id LOOP
		RAISE NOTICE 'def_id=% (%): %', def.def_id, def.name, def.sql;
		sum_td := 0;
		FOR i IN 1..def.n_runs LOOP
			-- run test
			t0 := clock_timestamp();
			EXECUTE def.sql;
			GET DIAGNOSTICS rows = ROW_COUNT;
			t1 := clock_timestamp();
			td := extract(milliseconds from t1-t0)::integer;

			IF i = 1 THEN
				res.n_rows = rows;
				IF rows < def.min_n_rows THEN
					RAISE WARNING 'def_id=%, #%: returned % rows; expected >%', def.def_id, i, rows, def.min_n_rows;
				END IF;
			ELSE
				IF rows != res.n_rows THEN
					RAISE WARNING 'def_id=%, #%: returned % rows; iteration 1 returned % rows', def.def_id, i, rows, res.n_rows;
				END IF;
			END IF;
			
			IF td > def.max_time THEN
				RAISE WARNING 'def_id=%, #%: time exceeded max_time (% ms > % ms)', def.def_id, i, td, def.max_time;
			END IF;
	
			res.times[i] = td;
			sum_td := sum_td + td;

			RAISE NOTICE '  #%: % rows, % ms', i, rows, td;
		END LOOP;

		res.avg_time = sum_td / def.n_runs;
		IF res.avg_time > def.max_avg_time THEN
			RAISE WARNING 'def_id=%: avg_time (% ms) exceeed max_av_time (% ms)', def.def_id, res.avg_time, def.max_time;
		END IF;

		res.def_id := def.def_id;
		res.run_id := rid;
		res.had_error := FALSE;

		INSERT INTO perftest_result(def_id,run_id,had_error,n_rows,times,avg_time)
			VALUES (res.def_id,res.run_id,res.had_error,res.n_rows,res.times,res.avg_time);
	END LOOP;

	update perftest_run set stop_ts=clock_timestamp()::timestamp where run_id=rid;
END;
$_$;

