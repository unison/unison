create table ncbi.homologene (
	hid integer not null,
	tax_id integer not null,
	gene_id integer not null,
	gene_symbol text not null,
	gi text not null,
	acc text not null primary key
) without oids;

create index homologene_gene_id on ncbi.homologene(gene_id);
create index homologene_acc_hid on ncbi.homologene(acc,hid);
create index homologene_hid_acc on ncbi.homologene(hid,acc);

grant select on ncbi.homologene to public;
comment on table ncbi.homologene is 'NCBI HomoloGene';
