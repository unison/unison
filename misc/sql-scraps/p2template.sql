\echo =======================================================================
\echo $Id: prospect2.sql,v 1.2 2002/11/27 00:05:54 rkh Exp $
-- p2template -- templates (presumably fssp or scop records)
-- TODO: before trigger to require pseq_id is from pdbc

create table p2template (
	p2template_id	serial,
	pseq_id			integer			not null default null,
	name			text			not null default null,
	len				integer			not null default null,
	ncores			integer			not null default null,

	constraint pseq_exists
		foreign key (pseq_id)
		references pseq (pseq_id)
		on delete cascade
		on update cascade
	);

create unique index p2template_name_uniqueness on p2template (upper(name));
