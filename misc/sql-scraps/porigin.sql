\echo =======================================================================
\echo $Id$
-- porigin -- origin of protein sequences & aliases

create table porigin (
	porigin_id		serial,
	origin			text			not null
	);
create unique index porigin_origin_idx on porigin (upper(origin));

comment on table porigin				is 'origin (database or algorithm) of protein alias (sequence)';
comment on column porigin.porigin_id	is 'unique id for origin; default is serial number';
comment on column porigin.origin		is 'origin name (freetext)';
