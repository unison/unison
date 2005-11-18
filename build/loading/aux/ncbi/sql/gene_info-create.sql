create table ncbi.gene_info (
	tax_id integer not null,
	gene_id integer not null,
	symbol text,
	locus_tag text,
	synonyms text,
	xrefs text,
	chromosome text,
	map_loc text,
	descr text,
	type text,
	nom_auth_symbol text,
	nom_auth text,
	nom_status char(1)
) without oids;

create index gene_info_gene_id on ncbi.gene_info(gene_id);

comment on table ncbi.gene_info is 'NCBI Entrez Gene information';
grant select on ncbi.gene_info to PUBLIC;
