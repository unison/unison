\echo =======================================================================
\echo $Id: palias.sql,v 1.2 2002/11/27 00:05:52 rkh Exp $
-- palias -- names of pseq entries

create table palias (
	palias_id			serial,
	pseq_id				integer		not null,
	porigin_id			integer		not null,
	alias				text		not null,
	descr				text,

	constraint palias_pseq_exists
		foreign key (pseq_id)
		references pseq (pseq_id)
		on delete cascade
		on update cascade,

	constraint palias_porigin_exists
		foreign key (porigin_id)
		references porigin (porigin_id)
		on delete cascade
		on update cascade,

	constraint palias_unique_in_origin
		unique (porigin_id,alias)
	);


-- additional constraint for circular reference between pseq and palias
alter table pseq
	add constraint pseq_palias_exists
	foreign key (palias_id)
	references palias (palias_id);
