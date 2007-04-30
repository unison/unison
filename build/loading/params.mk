## params.mk -- Unison loading configuration and options
## $Id: params.mk,v 1.25 2007/02/01 22:00:01 mukhyala Exp $

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
REFSEQ_DIR:=${RESEARCH_PREFIX}/data/public/refseq
GENESEQ_DIR:=${RESEARCH_PREFIX}/data/public/geneseq
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
PAPROSPECT_PARAMS_ID:=50
PAPROSPECT_PMODELSET_ID:=20


############################################################################
#### PAHMM
PFAM_DIR=${RESEARCH_PREFIX}/data/public/pfam-21.0
#OBSOLETE: PAHMM_PARAMS_ID:=43
#OBSOLETE: PAHMM_ORIGIN_ID:=$(shell ${PSQL_DCMD} 'select model_origin_id from params where params_id=${PAHMM_PARAMS_ID}')


############################################################################
#### PAPSEQ
PAPSEQ_PARAMS_ID:=3
PAPSEQ_CMDLINE=$(shell ${PSQL_DCMD} 'select commandline from params where params_id=${PAPSEQ_PARAMS_ID}')


############################################################################
#### PFANTIGENIC
PFANTIGENIC_PARAMS_ID:=4


############################################################################
#### PFBIGPI
PFBIGPI_PARAMS_ID:=19


############################################################################
#### PFPEPCOIL
PFPEPCOIL_PARAMS_ID:=37


############################################################################
#### PFREGEXP
PFREGEXP_PARAMS_ID:=12
PMREGEXP_PMODELSET_ID:=11

############################################################################
#### PFPSIPRED
PFPSIPRED_PARAMS_ID=17


############################################################################
#### PFTMDETECT
PFTMDETECT_PARAMS_ID:=9


############################################################################
#### PFTMHMM
PFTMHMM_PARAMS_ID:=29


############################################################################
#### PFSIGNALP
PFSIGNALP_PARAMS_ID:=28
PFSIGNALP_SEQS_PER_RUN:=100


############################################################################
#### PMAP
PMAP_PARAMS_ID:=48
PMAP_GENASM_ID:=3


############################################################################
#### PSDISPROT
DISPROT_PARAMS_ID:=39


############################################################################
#### PSPROTCOMP
PSPROTCOMP_PARAMS_ID:=20
PSPROTCOMP_SEQS_PER_RUN:=25

############################################################################
#### PROSITE
PROSITE_ORIGIN:='Prosite 19.28'

############################################################################
#### SEG
PFSEG_PARAMS_ID:=47

############################################################################
#### BLAST
BLAST_PARAMS_ID:=3
