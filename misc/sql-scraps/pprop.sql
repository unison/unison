\echo =======================================================================
\echo $Id$

create table pprop (
	pseq_id				integer		primary key default null 
		references pseq (pseq_id) on delete cascade on update cascade,

	sigcleave			float,	-- EMBOSS/sigcleave

	sigpredictp			float,	-- Genentech sigpredict

	tmdetect_ntm		integer,-- Genentech tmdetect (Tom Wu)
	tmdetect_maxp		float

	protcomp			text,	-- Softberry protcomp
	dgpi				text,	-- dgpi 
	);

create index pprop_pseq_id on pprop (pseq_id);

