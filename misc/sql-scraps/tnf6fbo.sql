create table tnf6fbo (
	q_pseq_id integer not null
		references pseq(pseq_id) on delete cascade on update cascade,
	s_pseq_id integer not null
		references pseq(pseq_id) on delete cascade on update cascade,
	eval double precision not null,
	score smallint not null,
	len	smallint not null,
	ide smallint not null,
	sim smallint not null,
	gap smallint not null
	) without oids;
create index tnf6fbo_eval on tnf6fbo(eval);
create index tnf6fbo_score on tnf6fbo(score);
create index tnf6fbo_len on tnf6fbo(len);
create index tnf6fbo_ide on tnf6fbo(ide);
create index tnf6fbo_sim on tnf6fbo(sim);
create index tnf6fbo_gap on tnf6fbo(gap);
grant select on tnf6fbo to public;
