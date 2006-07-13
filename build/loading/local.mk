## local.mk -- site-local definitions for Unison loading
## $Id: local.mk,v 1.7 2006/06/13 18:19:44 mukhyala Exp $


# Unison connection details
export PGHOST:=csb
export PGDATABASE:=csb-dev
export PGUSER:=unison
# NOTE: PGPASSWORD should be passed in the environment or in .pgpass
# but people insoucient regarding security could set PGPASSWORD here.


# Unison top-level directory
UNISON_HOME:=${HOME}/unison

# where to find executables
PATH:=${UNISON_HOME}/sbin:${UNISON_HOME}/bin:${UNISON_HOME}/misc
PATH:=${PATH}:${RESEARCH_PREFIX}/env/prd/i686-linux-2.6/bin
PATH:=${PATH}:/usr/pbs/bin:/usr/local/tools/bin:/usr/bin:/bin
export PATH

# where to find Unison Perl5 modules
PERL5LIB:=${UNISON_HOME}/perl5:${PERL5LIB}
export PERL5LIB

# perl regexp-based renamer
# this is only needed for PBS job submission
RENAME=${UNISON_HOME}/sbin/rerename



# Enable Genentech-specific loading
# This will require a lot of code and data that are
# not publicly available. 
GNE:=0
ifeq "$(shell /bin/hostname|cut -d. -f2-)" "gene.com"
$(warning NOTICE: enabling Genentech-specific configuration)
GNE:=1
endif



ifdef DEBUG
$(warning UNISON_HOME=${UNISON_HOME} )
$(warning PGUSER=${PGUSER} )
$(warning PGDATABASE=${PGDATABASE} )
$(warning PERL5LIB=${PERL5LIB} )
$(warning PATH=${PATH} )
$(warning QSUB=${QSUB} )
endif

ifndef PGPASSWORD
$(warning PGPASSWORD isn't set ) 	#'
endif
