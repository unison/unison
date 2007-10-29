create table "unison_aux".hugo (
	hgnc_id				integer primary key,   -- HGNC ID						
	approved_symbold	text not null,		   -- Approved Symbol				
	approved_name		text not null,		   -- Approved Name				
	status				text not null,		   -- Status						
	locus_type			text not null,		   -- Locus Type					
	previous_symbols	text,				   -- Previous Symbols			
	previous_names		text,				   -- Previous Names				
	aliases				text,				   -- Aliases						
	chromosome			text,				   -- Chromosome					
	date_approved		text,				   -- Date Approved				
	date_modified		text,				   -- Date Modified				
	date_name_changed	text,				   -- Date Name Changed			
	accession_numbers	text,				   -- Accession Numbers			
	enzyme_ids			text,				   -- Enzyme IDs					
	entrez_gene_id		text,				   -- Entrez Gene ID				
	mgd_id				text,				   -- MGD ID						
	specialist_db_links	text,				   -- spcialist DB links					
	pubmed_ids			text,				   -- Pubmed IDs					
	refseq_ids			text,				   -- RefSeq IDs					
	gene_family_name	text,				   -- Gene Family Name			
	gdb_id_md			text,				   -- GDB ID (mapped data)		
	entrez_gene_id_md	text,				   -- Entrez Gene ID (mapped data)
	omim_id_md			text,				   -- OMIM ID (mapped data)		
	refseq_md			text,				   -- RefSeq (mapped data)		
	uniprot_id_md		text				   -- UniProt ID (mapped data)    
) without oids;


grant select on "unison_aux".hugo to PUBLIC;

create unique index hugo_approved_symbold_idx on "unison_aux".hugo(approved_symbold);
create index hugo_approved_name_idx on "unison_aux".hugo(approved_name);
create index hugo_status_idx on "unison_aux".hugo(status);
create index hugo_entrez_gene_id_idx on "unison_aux".hugo(entrez_gene_id);
create index hugo_gene_family_name_idx on "unison_aux".hugo(gene_family_name);
create index hugo_gdb_id_md_idx on "unison_aux".hugo(gdb_id_md);
create index hugo_entrez_gene_id_md_idx on "unison_aux".hugo(entrez_gene_id_md);
create index hugo_omim_id_md_idx on "unison_aux".hugo(omim_id_md);
create index hugo_refseq_md_idx on "unison_aux".hugo(refseq_md);
create index hugo_uniprot_id_md_idx on "unison_aux".hugo(uniprot_id_md);


comment on table "unison_aux".hugo is 'Human Genome Organization official gene names';
comment on column "unison_aux".hugo.hgnc_id				is 'HGNC ID';
comment on column "unison_aux".hugo.approved_symbold	is 'Approved Symbol';
comment on column "unison_aux".hugo.approved_name		is 'Approved Name';
comment on column "unison_aux".hugo.status				is 'Status';
comment on column "unison_aux".hugo.locus_type			is 'Locus Type';
comment on column "unison_aux".hugo.previous_symbols	is 'Previous Symbols';
comment on column "unison_aux".hugo.previous_names		is 'Previous Names';
comment on column "unison_aux".hugo.aliases				is 'Aliases';
comment on column "unison_aux".hugo.chromosome			is 'Chromosome';
comment on column "unison_aux".hugo.date_approved		is 'Date Approved';
comment on column "unison_aux".hugo.date_modified		is 'Date Modified';
comment on column "unison_aux".hugo.date_name_changed	is 'Date Name Changed';
comment on column "unison_aux".hugo.accession_numbers	is 'Accession Numbers';
comment on column "unison_aux".hugo.enzyme_ids			is 'Enzyme IDs';
comment on column "unison_aux".hugo.entrez_gene_id		is 'Entrez Gene ID';
comment on column "unison_aux".hugo.mgd_id			is 'MGD ID';
comment on column "unison_aux".hugo.specialist_db_links		is 'links to specialist databases';
comment on column "unison_aux".hugo.pubmed_ids			is 'Pubmed IDs';
comment on column "unison_aux".hugo.refseq_ids			is 'RefSeq IDs';
comment on column "unison_aux".hugo.gene_family_name	is 'Gene Family Name';
comment on column "unison_aux".hugo.gdb_id_md			is 'GDB ID (mapped data)';
comment on column "unison_aux".hugo.entrez_gene_id_md	is 'Entrez Gene ID (mapped data)';
comment on column "unison_aux".hugo.omim_id_md			is 'OMIM ID (mapped data)';
comment on column "unison_aux".hugo.refseq_md			is 'RefSeq (mapped data)';
comment on column "unison_aux".hugo.uniprot_id_md		is 'UniProt ID (mapped data)';

