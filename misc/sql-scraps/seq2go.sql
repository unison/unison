create table unison.seq2go (
	pseq_id integer NOT NULL
		references pseq(pseq_id) on delete cascade on update cascade,
	go_id integer  NOT NULL
		references gong.node(go_id) on delete cascade on update cascade,
	reference text NOT NULL,
	evidence text NOT NULL,
	) without oids;
