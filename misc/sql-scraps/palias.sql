-- ===========================================================================
-- palias table -- names of pseq entries
create table palias (
	palias_id			serial,
	pseq_id				integer		not null,
	porigin_id			integer		not null,
	alias				text		not null,

	constraint pseq_exists
		foreign key (pseq_id)
		references pseq (pseq_id)
		on delete cascade
		on update cascade,

	constraint porigin_exists
		foreign key (porigin_id)
		references porigin (porigin_id)
		on delete cascade
		on update cascade

	-- constraint one_alias_per_seq_per_ori unique (pseq_id,porigin_id)
	);
