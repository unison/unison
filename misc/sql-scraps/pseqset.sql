create table pseqset (
	pset_id			integer,
	pseq_id			integer,

	constraint pset_id_exists	-- update set membership if pset is
		foreign key (pset_id)	-- udpated or deleted
		references pset (pset_id)
		on delete cascade
		on update cascade,

	constraint pseq_id_exists	-- ditto for sequence
		foreign key (pseq_id)
		references pseq (pseq_id)
		on delete cascade
		on update cascade
	);

create index pseqset_pset_id on pseqset (pset_id);
create index pseqset_pseq_id on pseqset (pseq_id);
