create table ncbi.generif (
	tax_id integer not null,
	gene_id integer not null,
	pubmed_ids text,
	last_update timestamp not null,
	generif text not null
) without oids;

create index generif_gene_id on ncbi.generif(gene_id);

comment on table ncbi.generif is 'NCBI Entrez Gene References into Function';
grant select on ncbi.generif to PUBLIC;
