\echo =======================================================================
\echo $Id$

create table pftype (
	pftype_id		serial,
	name			text
	);

create function pftype_id_lookup (text) returns integer as 
	'select pftype_id from pftype where name = $1' language 'sql';
