\echo =======================================================================
\echo $Id: porigin.sql,v 1.3 2002/12/10 20:18:13 rkh Exp $
-- porigin -- origin of protein sequences & aliases

create table porigin (
	porigin_id		serial unique,
	origin			text			not null,
	url				text		-- with %s placeholder for alias
	);
create unique index porigin_origin_idx on porigin (upper(origin));

comment on table porigin				is 'origin (database or algorithm) of protein alias (sequence)';
comment on column porigin.porigin_id	is 'unique id for origin; default is serial number';
comment on column porigin.origin		is 'origin name (freetext)';
