## params.mk -- Unison loading configuration and options
## $Id: params.mk,v 1.3 2005/11/09 03:24:56 rkh Exp $



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




############################################################################
#### PAPROSPECT
PAPROSPECT_PARAMS_ID:=1
PAPROSPECT_PMODELSET_ID:=10


############################################################################
#### PAHMM
PAHMM_PARAMS_ID:=27
PAHMM_PORIGIN_ID:=$(shell ${PSQL} -UPUBLIC -Atc 'select model_porigin_id from params where params_id=${PAHMM_PARAMS_ID}')


############################################################################
#### PFBIGPI
PFBIGPI_PARAMS_ID:=19


############################################################################
#### PFREGEXP
PFREGEXP_PARAMS_ID:=12
ITxM_PMODELSET_ID:=11


############################################################################
#### PFSSP_PSIPRED
PFSSP_PSIPRED_PARAMS_ID=17


############################################################################
#### PFTMHMM
PFTMHMM_PARAMS_ID:=29


############################################################################
#### PSPROTCOMP
PSPROTCOMP_PARAMS_ID:=20
PSPROTCOMP_SEQS_PER_RUN:=25


