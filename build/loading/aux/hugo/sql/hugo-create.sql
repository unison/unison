create table unison.hugo (
	hgnc_id				integer primary key,   -- HGNC ID						
	approved_symbold	text not null,		   -- Approved Symbol				
	approved_name		text not null,		   -- Approved Name				
	status				text not null,		   -- Status						
	locus_type			text not null,		   -- Locus Type					
	previous_symbols	text not null,		   -- Previous Symbols			
	previous_names		text not null,		   -- Previous Names				
	aliases				text not null,		   -- Aliases						
	chromosome			text not null,		   -- Chromosome					
	date_approved		text not null,		   -- Date Approved				
	date_modified		text not null,		   -- Date Modified				
	date_name_changed	text not null,		   -- Date Name Changed			
	accession_numbers	text not null,		   -- Accession Numbers			
	enzyme_ids			text not null,		   -- Enzyme IDs					
	entrez_gene_id		text not null,		   -- Entrez Gene ID				
	mgd_id				text not null,		   -- MGD ID						
	misc_ids			text not null,		   -- Misc IDs					
	pubmed_ids			text not null,		   -- Pubmed IDs					
	refseq_ids			text not null,		   -- RefSeq IDs					
	gene_family_name	text not null,		   -- Gene Family Name			
	gdb_id_md			text not null,		   -- GDB ID (mapped data)		
	entrez_gene_id_md	text not null,		   -- Entrez Gene ID (mapped data)
	omim_id_md			text not null,		   -- OMIM ID (mapped data)		
	refseq_md			text not null,		   -- RefSeq (mapped data)		
	uniprot_id_md		text not null		   -- UniProt ID (mapped data)    
) without oids;

comment on table unison.hugo is 'Human Genome Organization official gene names';
grant select on unison.hugo to PUBLIC;
