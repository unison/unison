\echo =======================================================================
\echo $Id$
-- meta -- unison database meta information

create table meta (
	key		text		primary key not null default null,
	value	text
	);

