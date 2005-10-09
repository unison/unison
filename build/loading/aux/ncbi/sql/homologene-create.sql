create table ncbi.homologene (
	hid integer not null,
	tax_id integer not null,
	gene_id integer not null,
	gene_symbol text not null,
	gi text not null,
	acc text not null primary key
) without oids;
