create table unison.hugo (
	hgnc_id				integer primary key,
	approved_symbold	text not null,
	approved_name		text not null,
	status				text not null,
	locus_type			text not null,
	previous_symbols	text not null,
	previous_names		text not null,
	aliases				text not null,
	chromosome			text not null,
	date_approved		text not null,
	date_modified		text not null,
	date_name_changed	text not null,
	accession_numbers	text not null,
	enzyme_ids			text not null,
	entrez_gene_id		text not null,
	mgd_id				text not null,
	misc_ids			text not null,
	pubmed_ids			text not null,
	refseq_ids			text not null,
	gene_family_name	text not null,
	gdb_id				text not null,
	omim_id				text not null,
	refseq				text not null,
	uniprot_id			text not null
) without oids;

comment on table unison.hugo is 'Human Genome Organization official gene names';
grant select on unison.hugo to PUBLIC;
