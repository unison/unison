create table ncbi.gene2unigene (
	gene_id integer not null,
	unigene_acc text not null
) without oids;

create index gene2unigene_gene_id on ncbi.gene2unigene(gene_id);
create index gene2unigene_unigene_acc on ncbi.gene2unigene(unigene_acc);

comment on table ncbi.gene2unigene is 'NCBI Entrez Gene <-> UniGene mapping';
grant select on ncbi.gene2unigene to PUBLIC;
