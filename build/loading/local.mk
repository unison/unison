## local.mk -- site-local definitions for Unison loading
## $Id: local.mk,v 1.1 2005/07/18 21:27:40 rkh Exp $


# Unison connection details
export PGHOST:=csb
export PGDATABASE:=csb-dev
export PGUSER:=loader
# NOTE: the corresponding PGPASSWORD must be passed in the environment 


COMPBIO:=${COMPBIO_PREFIX}

# Unison top-level directory
UNISON_HOME:=${HOME}/unison

PERL5LIB:=${UNISON_HOME}/perl5:${PERL5LIB}
export PERL5LIB

# Where to find various computational biology data required for
# Unison loading
SHARE:=${COMPBIO_PREFIX}/share

PATH:=${UNISON_HOME}/sbin:${UNISON_HOME}/bin:${UNISON_HOME}/misc
PATH:=${PATH}:${COMPBIO_EPREFIX}/bin:${COMPBIO_PREFIX}/bin
PATH:=${PATH}:/usr/pbs/bin:/usr/local/tools/bin:/usr/bin:/bin
export PATH


# WARNING: DEPENDENCY ON REECE'S HOME DIRECTORY HERE
RENAME=~rkh/opt/bin/rerename
