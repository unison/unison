create table ncbi.mim2gene (
	mim_id integer not null,
	gene_id integer not null,
	type text not null
) without oids;

create index mim2gene_mim_id on ncbi.mim2gene(mim_id);
create index mim2gene_gene_id on ncbi.mim2gene(gene_id);

comment on table ncbi.mim2gene is 'NCBI Entrez Gene <-> MIM mapping';
grant select on ncbi.mim2gene to PUBLIC;
