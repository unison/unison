\echo =======================================================================
\echo $Id$
-- non-exclusive (i.e., overlapping) sets of pseqs

create table pset (
	pset_id		serial,
	name		text			unique not null
	);

create index pset_setname_idx on pset (name);
