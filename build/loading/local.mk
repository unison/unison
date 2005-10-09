## local.mk -- site-local definitions for Unison loading
## $Id: local.mk,v 1.2 2005/09/13 15:05:14 rkh Exp $


# Unison connection details
export PGHOST:=csb
export PGDATABASE:=csb-dev
export PGUSER:=loader
# NOTE: the corresponding PGPASSWORD must be passed in the environment 


# Unison top-level directory
UNISON_HOME:=${HOME}/unison

PERL5LIB:=${UNISON_HOME}/perl5:${PERL5LIB}
export PERL5LIB

PATH:=${UNISON_HOME}/sbin:${UNISON_HOME}/bin:${UNISON_HOME}/misc
PATH:=${PATH}:${COMPBIO_EPREFIX}/bin:${COMPBIO_PREFIX}/bin
PATH:=${PATH}:/usr/pbs/bin:/usr/local/tools/bin:/usr/bin:/bin
export PATH

PROSPECT_PATH:=${COMPBIO_EPREFIX}/opt/prospect
export PROSPECT_PATH

# WARNING: DEPENDENCY ON REECE'S HOME DIRECTORY HERE
RENAME=~rkh/opt/bin/rerename

# Where to find various computational biology data required for
# Unison loading
UNIPROT_DIR=${COMPBIO_PREFIX}/share/uniprot
PFAM_DIR=${COMPBIO_PREFIX}/share/pfam-18.0
