\echo =======================================================================
\echo $Id$
-- pstr -- protein structure reference

-- note: pdb files (e.g., 2tnf) may have multiple chains, referred to here
-- as pdbc (e.g., 2tnfa), each of which must have an extant pseq.

create table pstr (
	pstr_id			serial,
	pseq_id			integer not null default null,
	pdbc			varchar(5),	-- pdb + (optional) chain, eg. 3ptbA

	constraint pseq_id_exists
		foreign key (pseq_id)
		references pseq (pseq_id)
		on delete cascade
		on update cascade,

	-- one pdbc per seq, one seq per pdbc
	constraint pseq_pdbc_relation_is_exclusive unique (pseq_id,pdbc)
	);

-- unique enforces that each pstr (=pdbc) may have only one associated pseq
create unique index pstr_pdbc_idx on pstr (upper(pdbc));
