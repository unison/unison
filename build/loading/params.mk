## params.mk -- Unison loading configuration and options
## $Id: params.mk,v 1.26 2007/04/30 05:05:53 rkh Exp $

## XXX: We should get more params_id from pftype(preferred_params_id).

############################################################################
#### AUX DATA SOURCES
GENE_DIR:=${RESEARCH_PREFIX}/data/public/ncbi/gene
HOMOLOGENE_VERSION:=46.1
HOMOLOGENE_DATA:=${RESEARCH_PREFIX}/data/public/ncbi/pub/HomoloGene/build${HOMOLOGENE_VERSION}/homologene.data
GO_DIR:=${RESEARCH_PREFIX}/data/public/go


############################################################################
#### PSEQ
CCDS_DIR:=${RESEARCH_PREFIX}/data/mirrors/ftp.ncbi.nih.gov/pub/CCDS
COSMIC_DIR:=${RESEARCH_PREFIX}/data/mirrors/ftp.sanger.ac.uk/pub/CGP/cosmic/fasta_files
ENSEMBL_DIR:=${RESEARCH_PREFIX}/data/public/ensembl
GENESEQ_DIR:=${RESEARCH_PREFIX}/data/licensed/geneseq
GNE_PDB_DIR=${RESEARCH_PREFIX}/data/structures/final
HUGE_DIR:=${KAZUSA_DIR}/huge
KAZUSA_DIR:=${RESEARCH_PREFIX}/data/public/mirrors/ftp.kazusa.or.jp/pub
NR_FA:=${RESEARCH_PREFIX}/data/public/seqdb/aa/nr.fa
PATAA_FA:=${RESEARCH_PREFIX}/data/public/seqdb/aa/pataa.fa
PDB_DIR=${RESEARCH_PREFIX}/data/public/pdb/divided.pdb
REFSEQ_DIR:=${RESEARCH_PREFIX}/data/public/refseq
ROUGE_DIR:=${KAZUSA_DIR}/rouge
STRING_DIR:=${RESEARCH_PREFIX}/data/mirrors/string.embl.de/newstring_download
UNIPROT_DIR:=${RESEARCH_PREFIX}/data/public/uniprot


############################################################################
#### PAPROSPECT
PROSPECT_PATH:=${RESEARCH_EPREFIX}/opt/prospect
export PROSPECT_PATH

############################################################################
#### PAHMM
PFAM_DIR=${RESEARCH_PREFIX}/data/public/pfam

############################################################################
#### PMAP
PMAP_GENASM_ID:=3
