create table pfnetphos (
	   prob float NOT NULL,
	   kinase_id integer not null
   			 references pfnetphos_kinase on delete cascade on update cascade,

	   CONSTRAINT one_residue
	      CHECK (start=stop),

	   CONSTRAINT valid_kinase_type 
		  CHECK (kinase in ('ATM', 'CaM-II', 'cdc2', 'cdk5', 'CKI', 'CKII',
		  'DNAPK', 'EGFR', 'GSK3', 'INSR', 'p38MAPK', 'PKA', 'PKB', 'PKC',
		  'PKG', 'RSK', 'SRC', 'unsp')),

	   CONSTRAINT STY_residue
	      CHECK (substr(pseq_id_sequence(pseq_id),start,1) in ('S','T','Y'))
) INHERITS (pfeature);

alter table pfnetphos alter column pftype_id set default pftype_id('netphos');

COMMENT on table pfnetphos is 'S,T,Y phosphorylation prediction by netphos';

create unique index pfnetphos_unique_idx on pfnetphos (pseq_id,params_id,start,kinase);
create index pfnetphos_q on pfnetphos(pseq_id);
create index pfnetphos_kinase_idx on pfnetphos(kinase);

GRANT SELECT ON pfnetphos TO PUBLIC;
GRANT INSERT ON pfnetphos TO loader;
