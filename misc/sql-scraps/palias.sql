\echo =======================================================================
\echo $Id$
-- palias -- names of pseq entries

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
		on update cascade,

	-- each alias must be unique within that origin
	constraint alias_must_be_unique_for_origin unique (porigin_id,alias)

	);
