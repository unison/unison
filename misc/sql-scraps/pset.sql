\echo =======================================================================
\echo $Id: pset.sql,v 1.2 2002/11/27 00:05:54 rkh Exp $
-- non-exclusive (i.e., overlapping) sets of pseqs

create table pset (
	pset_id		serial,
	name		text			not null default null
	);

create unique index pset_name_idx on pset (upper(name));
