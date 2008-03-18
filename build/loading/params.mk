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
ENSEMBL_DIR:=${RESEARCH_PREFIX}/data/public/ensembl
PDB_DIR=${RESEARCH_PREFIX}/data/public/pdb/divided.pdb
GNE_PDB_DIR=${RESEARCH_PREFIX}/data/structures/final
REFSEQ_DIR:=${RESEARCH_PREFIX}/data/public/refseq
GENESEQ_DIR:=${RESEARCH_PREFIX}/data/licensed/geneseq
KAZUSA_DIR:=${RESEARCH_PREFIX}/data/public/mirrors/ftp.kazusa.or.jp/pub
HUGE_DIR:=${KAZUSA_DIR}/huge
ROUGE_DIR:=${KAZUSA_DIR}/rouge
CCDS_HUMAN_PATH:=${RESEARCH_PREFIX}/data/public/mirrors/ftp.ncbi.nlm.nih.gov/pub/CCDS/current/CCDS_protein.03032005.faa.gz
UNIPROT_DIR:=${RESEARCH_PREFIX}/data/public/uniprot
PATAA_FA:=${RESEARCH_PREFIX}/data/public/seqdb/aa/pataa.fa
NR_FA:=${RESEARCH_PREFIX}/data/public/seqdb/aa/nr.fa
COSMIC_DIR:=${RESEARCH_PREFIX}/data/public/mirrors/ftp.sanger.ac.uk/pub/CGP/cosmic/fasta_files


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
