create table dali.dccp (
	aln_id integer primary key not null,
	q_pdbc text not null,
	s_pdbc text not null,
	raw real NOT NULL,
	z_score real NOT NULL,
	pct_ide smallint NOT NULL,
	rmsd real NOT NULL,
	U1 real[9] NOT NULL,
	T1 real[3] NOT NULL,
	U2 real[9] NOT NULL,
	T2 real[3] NOT NULL,
	eq_res smallint NOT NULL
	) without oids;

create index dccp_q_pdbc_pct_ide on dali.dccp(q_pdbc,pct_ide);
create index dccp_s_pdbc_pct_ide on dali.dccp(s_pdbc,pct_ide);

grant select on dali.dccp to PUBLIC;

comment on table dali.dccp is 'DALI alignment records';




create table dali.fragments (
	aln_id integer NOT NULL
		references dali.dccp(aln_id) on delete cascade on update cascade,
	-- NOTE: dali_fragments.gz contains lines (2 to be exact) which have NULLs
	-- I don't know the significance of this. See fragements-to-copy
	q_start smallint, -- NOT NULL,
	q_stop smallint, -- NOT NULL,
	s_start smallint, -- NOT NULL,
	s_stop smallint -- NOT NULL
	) without oids;

create index dccp_aln_id on dali.fragments(aln_id);

grant select on dali.fragments to PUBLIC;

comment on table dali.fragments is 'aligned fragments for each dccp (>=1 per dccp)';
