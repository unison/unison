-- ===========================================================================
-- porigin table -- origin of protein sequences & aliases
create table porigin (
	porigin_id		serial,
	origin			text			not null unique
	);

comment on table porigin				is 'origin (database or algorithm) of protein alias (sequence)';
comment on column porigin.porigin_id	is 'unique id for origin; default is serial number';
comment on column porigin.origin		is 'origin name (freetext)';
