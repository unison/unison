## local.mk -- site-local definitions for Unison loading
## $Id$

export PGUSER:=loader
export PGHOST:=csb
export PGDATABASE:=csb-dev

COMPBIO:=/gne/compbio

UNISON_HOME:=${HOME}/unison

PATH:=${UNISON_HOME}/sbin:${UNISON_HOME}/bin:${UNISON_HOME}/misc
PATH:=${PATH}:${COMPBIO_EPREFIX}/bin:${COMPBIO_PREFIX}/bin
PATH:=${PATH}:/usr/pbs/bin:/usr/local/tools/bin:/usr/bin:/bin
export PATH

export PERL5LIB:=${UNISON_HOME}/perl5:${PERL5LIB}

RENAME=${HOME}/opt/bin/rerename
