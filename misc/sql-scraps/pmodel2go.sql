create table unison.pmodel2go (
	pmodel_id integer NOT NULL,
-- 		sigh... can't enforce fk integrity to multple subclasses of pmodel
--		references pmodel(pseq_id) on delete cascade on update cascade,
	go_id integer  NOT NULL
		references gong.node(go_id) on delete cascade on update cascade,
	reference text NOT NULL,
	evidence text NOT NULL,
	) without oids;
