drop table perftest_result;
drop table perftest_run;
drop table perftest_platform;
drop table perftest_def;


create table perftest_def (
	def_id serial 	primary key,
	current		boolean not null	default TRUE,

	ordr		smallint not null	default 10000,	
	name		text	not null	unique,
	sql			text 	not null,
	n_runs		smallint not null,
	min_n_rows	integer not null,
	max_time	integer not null,
	max_avg_time integer not null,

	constraint runs_gt_zero check (n_runs>0),
	constraint min_n_rows_gt_zero check (min_n_rows>0),
	constraint max_time_gt_zero check (max_time>0),
	constraint max_avg_time_gt_zero check (max_avg_time>=0),
	constraint max_avg_time_le_max_time check (max_avg_time<=max_time)
);
comment on table perftest_def is 'Unison regression test definitions';
comment on column perftest_def.def_id is 'unique test definition identifier ';
comment on column perftest_def.ordr is 'order in which test should be run';
comment on column perftest_def.name is 'unique name for test';
comment on column perftest_def.sql is 'sql definition';
comment on column perftest_def.n_runs is 'number of runs for test';
comment on column perftest_def.min_n_rows is 'minimum number of rows expected for result set';
comment on column perftest_def.max_time is 'max time expected for a single test execution';
comment on column perftest_def.max_avg_time is 'max average time for all runs';
comment on column perftest_def.current is 'whether test should be executed for new test runs';
grant select on perftest_def to PUBLIC;


create table perftest_platform (
	platform_id serial	primary key,
	name 		text 	not null unique,
	date 		timestamp not null default now(),
	current		boolean not null default TRUE,
	locked		boolean	not null default FALSE,

	mac			macaddr not null,
	ip 			inet	not null,

	uname_s		text	not null,
	uname_n		text	not null,
	uname_r		text	not null,
	uname_m		text	not null,

	ram_gb		smallint not null,
	
	fs_type		text	not null,

	pg_version_str	text not null,
	pg_version	text	not null

	-- An enormous set of variables might affect performance (or even
	-- results) for a single database schema and data set.  Not included,
	-- for now: postgresql.conf options, analyze status, other users
	-- (locks!), fs block size, CPU freq, #cores, RAM speed, and lots else too.
);

CREATE OR REPLACE FUNCTION perftest_iu_trigger_fx()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$_$
BEGIN
	NEW.pg_version = substring(NEW.pg_version_str from E'^PostgreSQL (\\S+) ');
	RETURN NEW;
END;
$_$;

CREATE TRIGGER perftest_iu_trigger
BEFORE INSERT OR UPDATE ON perftest_platform
FOR EACH ROW EXECUTE PROCEDURE perftest_iu_trigger_fx();

comment on table perftest_platform is 'hardware and software platform for a set of test results';
comment on column perftest_platform.platform_id is 'unique id for a set of test results';
comment on column perftest_platform.name is 'platform name';
comment on column perftest_platform.date is 'date of test';
comment on column perftest_platform.current is 'whether this platform is currently interesting';
comment on column perftest_platform.mac is 'host MAC address';
comment on column perftest_platform.ip is 'IP address';
comment on column perftest_platform.uname_s is 'result of uname -s';
comment on column perftest_platform.uname_n is 'result of uname -n';
comment on column perftest_platform.uname_r is 'result of uname -r';
comment on column perftest_platform.uname_m is 'result of uname -m';
comment on column perftest_platform.ram_gb is 'total installed RAM, in GB';
comment on column perftest_platform.fs_type is 'PGDATA filesystem type and options';
comment on column perftest_platform.pg_version_str is 'text from version()';
comment on column perftest_platform.pg_version	is 'PostgreSQL x.y.z version';
grant select on perftest_platform to PUBLIC;


create table perftest_run (
	run_id serial	primary key,
	platform_id integer not null
		references perftest_platform(platform_id) on delete cascade on update cascade,
	start_ts	timestamp	not null,
	stop_ts  	timestamp,
	comments 	text
);
grant select on perftest_run to public;


create table perftest_result (
	def_id integer not null
		references perftest_def(def_id) on delete cascade on update cascade,
	run_id integer not null
		references perftest_run(run_id) on delete cascade on update cascade,
	had_error	boolean	not null,
	n_rows		integer,
	times		integer[],
	avg_time	integer,

	constraint one_result_per_def_platform unique (def_id,run_id),

	constraint n_rows_gt_zero check (n_rows>0),
	constraint avg_time_gt_zero	check (avg_time>0)
);
comment on table perftest_result is 'results for a single test on single platform';
comment on column perftest_result.def_id is 'test definition id';
comment on column perftest_result.run_id is 'test run id (implies one platform)';
comment on column perftest_result.had_error is 'whether there was an error/exception for this test';
comment on column perftest_result.n_rows is 'number of rows returned by this test';
comment on column perftest_result.times is 'vector of elapsed times for this test (see perftest_platform.n_runs)';
comment on column perftest_result.avg_time is 'average elapsed time for this test';
grant select on perftest_result to PUBLIC;



insert into perftest_def (n_runs,min_n_rows,max_time,max_avg_time,name,sql) values
	--nr    rows        t      <t>  name                              sql
	(  5,  25000,   53000,   53000, '7Q sequences'					, $$select * from pseq where seq~'QQQQQQQ'$$						),
	(  5,   3300,      90,      90, '100 pahmms'					, $$select * from pahmm_v where pseq_id<100$$						),
	(  1,     50,  360000,  360000, $$Bcl-2s$$						, $$select * from bcl2_zebrafish_domains_v where known='f'$$		),
	(  1,	 655,   31000,	 31000,	$$BH3 E3 Ligases (canned view)$$, $$select * from e3_and_bh3_cv$$									),
	(  1,	 182,   33000,	 33000,	$$Kunitz-type inhibitors (canned view)$$,	$$select * from tm_kunitz_cv where "#TM">0$$ 			),
	(  1,	3017,    6000,	  6000,	$$ITIMs (canned view)$$			, $$select * from ig_tm_itim_cv where eval<=1e-1 and tm_prob>0.6$$	),
	(  1,	1309,   43000,	 43000,	$$ITxMs (canned view)$$			, $$select * from itxm_w_unq_fam_v$$ 								)
;

insert into perftest_platform (name, ip, mac, uname_s, uname_n, uname_r, uname_m, ram_gb, fs_type, pg_version_str) VALUES
	( 'csb V40Z',  '128.137.27.14'  , '00:09:3D:00:49:20', 'Linux', 'csb', '2.6.13-15.13-smp' , 'x86_64', 32, 'reiserfs (rw,noatime,data=writeback)', 'PostgreSQL 8.2.4 on x86_64-unknown-linux-gnu, compiled by GCC gcc (GCC) 4.0.2 20050901 (prerelease) (SUSE Linux)' ),
	( 'csb DL585', '128.137.125.204', '00:18:FE:75:7B:EF', 'Linux', 'csb', '2.6.16.21-0.8-smp', 'x86_64', 32, 'reiserfs (rw,noatime,data=writeback)', 'PostgreSQL 8.2.4 on x86_64-unknown-linux-gnu, compiled by GCC gcc (GCC) 4.1.0 (SUSE Linux)' )
;
