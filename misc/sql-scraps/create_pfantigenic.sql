create table pfantigenic (
	pseq_id integer not null
		references pseq(pseq_id) on update cascade on delete cascade,
	score float not null,
	max_pos smallint not null
) INHERITS (pfeature) WITHOUT OIDS;

create index pfantigenic_pkey on pfantigenic(pseq_id);
create unique index pfantigenic_unique on pfantigenic(pseq_id,start,stop,run_id);
create index pfantigenic_score on pfantigenic(score);

COMMENT ON TABLE pfantigenic IS 'EMBOSS antigenic features';
COMMENT ON column pfantigenic.score IS 'antigenic score';
