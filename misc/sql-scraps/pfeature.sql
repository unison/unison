\echo =======================================================================
\echo $Id: pfeature.sql,v 1.2 2002/11/27 00:05:53 rkh Exp $
-- pfeature -- tables for storing abstract protein sequence features

create table pfeature (
	pfeature_id		serial unique,
	pseq_id			integer			not null default null,
	pftype_id		integer			not null default null,
	start			integer,
	stop			integer,
	quality			float,
	comment			text,

	constraint pseq_exists
		foreign key (pseq_id)
		references pseq (pseq_id)
		on delete cascade
		on update cascade,

	constraint pftype_exists
		foreign key (pftype_id)
		references pftype (pftype_id)
		on delete cascade
		on update cascade
	);

create index pfeature_pseq_id_idx on pfeature (pseq_id);
create index pfeature_pftype_id_idx on pfeature (pftype_id);
create unique index nonredundant_features on pfeature (pseq_id,pftype_id,start,stop);
