## import sst unq-pro-dna and related tables

update: sst.log

include ../../common.mk
include ../../local.mk
include ../../params.mk

ifndef SSTPASS
$(error SSTPASS isn't set ) 	#'
endif

sst.log: sst.sql
	(time -p psql -Uunison -f $<) >$@.err 2>&1
	/bin/mv -f $@.err $@

.PRECIOUS: sst.sql
sst.sql: ${FORCE}
	(time -p ./sst-import >$@.tmp) 2>$@.err \
	&& /bin/mv -f $@.err $@.log && /bin/mv -f $@.tmp $@


cleaner:: clean
	/bin/rm -f sst.sql*
cleanest:: cleaner
	/bin/rm -f sst.log*
