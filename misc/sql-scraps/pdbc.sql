\echo =======================================================================
\echo $Id: pdbc.sql,v 1.2 2002/11/27 00:05:54 rkh Exp $
-- pdbc -- protein structure reference

-- note: pdb files (e.g., 2tnf) may have multiple chains, referred to here
-- as pdbc (e.g., 2tnfa), each of which must have an extant pseq.

create table pdbc (
	pdbc_id			serial,
	pseq_id			integer not null default null,
	pdbc			varchar(5),	-- pdb + (optional) chain, eg. 3ptbA

	constraint pseq_id_exists
		foreign key (pseq_id)
		references pseq (pseq_id)
		on delete cascade
		on update cascade
	);
