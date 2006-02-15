## params.mk -- Unison loading configuration and options
## $Id: params.mk,v 1.10 2006/01/20 00:49:47 rkh Exp $


############################################################################
#### AUX DATA SOURCES
GENE_DIR:=${COMPBIO_PREFIX}/share/ncbi/gene
HOMOLOGENE_VERSION:=46.1
HOMOLOGENE_DATA:=${COMPBIO_PREFIX}/share/ncbi/pub/HomoloGene/build${HOMOLOGENE_VERSION}/homologene.data



############################################################################
#### PSEQ
ENSEMBL_DIR:=${COMPBIO_PREFIX}/share/ensembl
PDB_DIR=${COMPBIO_PREFIX}/share/pdb/divided.pdb
REFSEQ_DIR:=${COMPBIO_PREFIX}/share/refseq
GENESEQ_DIR:=${COMPBIO_PREFIX}/share/geneseq
KAZUSA_DIR:=${COMPBIO_PREFIX}/share/mirrors/zearth.kazusa.or.jp/pub
HUGE_DIR:=${KAZUSA_DIR}/huge
ROUGE_DIR:=${KAZUSA_DIR}/rouge
CCDS_HUMAN_PATH:=${COMPBIO_PREFIX}/share/mirrors/ftp.ncbi.nlm.nih.gov/pub/CCDS/current/CCDS_protein.03032005.faa.gz
UNIPROT_DIR:=${COMPBIO_PREFIX}/share/uniprot
PATAA_DIR:=${COMPBIO_PREFIX}/share/pataa/



############################################################################
#### PAPROSPECT
PROSPECT_PATH:=${COMPBIO_EPREFIX}/opt/prospect
export PROSPECT_PATH
PAPROSPECT_PARAMS_ID:=31
PAPROSPECT_PMODELSET_ID:=20


############################################################################
#### PAHMM
PFAM_DIR=${COMPBIO_PREFIX}/share/pfam-19.0
PAHMM_PARAMS_ID:=34
PAHMM_PORIGIN_ID:=$(shell ${PSQL_DCMD} 'select model_porigin_id from params where params_id=${PAHMM_PARAMS_ID}')


############################################################################
#### PFANTIGENIC
PFANTIGENIC_PARAMS_ID:=4


############################################################################
#### PFBIGPI
PFBIGPI_PARAMS_ID:=19


############################################################################
#### PFREGEXP
PFREGEXP_PARAMS_ID:=12


############################################################################
#### PFPSIPRED
PFPSIPRED_PARAMS_ID=17


############################################################################
#### PFTMHMM
PFTMHMM_PARAMS_ID:=29


############################################################################
#### PFSIGNALP
PFSIGNALP_PARAMS_ID:=28
PFSIGNALP_SEQS_PER_RUN:=100


############################################################################
#### PMAP
PMAP_PARAMS_ID:=32


############################################################################
#### PSPROTCOMP
PSPROTCOMP_PARAMS_ID:=20
PSPROTCOMP_SEQS_PER_RUN:=25
