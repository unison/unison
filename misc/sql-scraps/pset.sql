\echo =======================================================================
\echo $Id: pset.sql,v 1.3 2002/12/10 19:48:12 rkh Exp $
-- non-exclusive (i.e., overlapping) sets of pseqs

create table pset (
	pset_id		serial unique,
	name		text			not null default null
	);

create unique index pset_name_idx on pset (upper(name));
