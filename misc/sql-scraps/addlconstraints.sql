\echo =======================================================================
\echo $Id$

-- additional constraint for circular reference between pseq and palias

alter table pseq
	add constraint alias_exists
	foreign key (palias_id)
	references palias (palias_id);
