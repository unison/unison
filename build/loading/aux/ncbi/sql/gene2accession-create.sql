create table ncbi.gene2accession (
	tax_id integer not null,
	gene_id integer not null,
	status text,
	rna_acc text,
	rna_gi integer,
	pro_acc text,
	pro_gi integer,
	gen_acc text,
	gen_gi integer,
	gen_start integer,
	gen_end integer,
	gen_orient char(1),
	assembly text
) without oids;

create index gene2accession_gene_id on ncbi.gene2accession(gene_id);
create index gene2accession_rna_acc on ncbi.gene2accession(rna_acc);
create index gene2accession_pro_acc on ncbi.gene2accession(pro_acc);
create index gene2accession_gen_acc on ncbi.gene2accession(gen_acc);

comment on table ncbi.gene2accession is 'NCBI Entrez Gene <-> RefSeq mapping';
grant select on ncbi.gene2accession to PUBLIC;
