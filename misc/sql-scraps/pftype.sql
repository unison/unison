\echo =======================================================================
\echo $Id: pftype.sql,v 1.3 2002/12/10 19:48:11 rkh Exp $

create table pftype (
	pftype_id		serial unique,
	name			text
	);
