create table ncbi.gene2go (
	tax_id integer not null,
	gene_id integer not null,
	go_id text not null,
	evidence text not null,
	qualifier text,
	term text not null,
	pubmed_id text
) without oids;

create index gene2go_gene_id on ncbi.gene2go(gene_id);
create index gene2go_go_id on ncbi.gene2go(go_id);

comment on table ncbi.gene2go is 'NCBI Entrez Gene <-> GO mapping';
grant select on ncbi.gene2go to PUBLIC;
