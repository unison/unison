## local.mk -- site-local definitions for Unison loading
## $Id: local.mk,v 1.13 2006/12/13 19:52:05 mukhyala Exp $


# Unison connection details
export PGHOST:=csb
export PGDATABASE:=csb-dev
export PGUSER:=unison
# NOTE: PGPASSWORD should be passed in the environment or in .pgpass
# but people insoucient regarding security could set PGPASSWORD here.


# Unison top-level directory
UNISON_HOME:=${HOME}/unison
export UNISON_HOME

# where to find executables
PATH:=${UNISON_HOME}/tools/sbin:${UNISON_HOME}/tools/bin:${UNISON_HOME}/build/loading/bin:${PATH}
PATH:=${PATH}:${RESEARCH_PREFIX}/env/prd/i686-linux-2.6/bin
PATH:=${PATH}:/usr/pbs/bin:/usr/local/tools/bin:/usr/bin:/bin
export PATH

# where to find Unison Perl5 modules
PERL5LIB:=${UNISON_HOME}/perl5:${PERL5LIB}
export PERL5LIB

# perl regexp-based renamer
# this is only needed for PBS job submission
RENAME=${UNISON_HOME}/tools/sbin/rerename



# Enable Genentech-specific loading
# GNE=1 will invoke a lot of code and data that are not publicly
# available, and cause errors when these files aren't found.
# dnsdomainname is not available on all platforms, and uname and cut
# locations vary, ergo full path is not used.
GNE:=0
ifeq "$(shell /bin/dnsdomainname)" "gene.com"
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
