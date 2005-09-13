include ../common.mk
include ../local.mk
include ../params.mk

default all: affyannot.log

affyannot.load: affyannot.sql
	psql -qaf $< 1>$@.err 2>&1
	/bin/mv -f $@.err $@.log; touch $@

.PRECIOUS: affyannot.sql
affyannot.sql:
	${UHOME}/misc/affyannot-import >$@.tmp 2>$@.err
	/bin/mv -f $@.err $@.log; /bin/mv -f $@.tmp $@
