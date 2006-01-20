# -*-Makefile-*-

YM=200601

update: go.log

# f!#$ers! my2pg now overwrites Makefile without warning
# #MY2PG:=../../../sbin/my2pg.pl

include ../../common.mk
include ../../local.mk
include ../../params.mk

Y=$(shell expr "${YM}" : '\(20..\)')
M=$(shell expr "${YM}" : '20..\(..\)')
GTT=go_$Y$M-termdb-tables
TABLES_TAR_GZ:=${COMPBIO_PREFIX}/share/go/full/$Y-$M-01/${GTT}.tar.gz


test: ${GTT}-untar.log

.PRECIOUS: ${GTT}-untar.log
${GTT}-untar.log: ${TABLES_TAR_GZ}
	tar -xzf $< >$@.tmp 2>&1
	/bin/mv -f $@.tmp $@


${GTT}/%.pgsql: ${GTT}/%.sql     ${GTT}-untar.log
	${MY2PG} $< >$@


${GTT}.sql: ${GTT}-untar.log
	perl -e 'while(my $$fn=shift) {' \
	-e 'my ($$t) = $$fn =~ m%(\w+)\.txt%;' \
	-e 'print "COPY go.$$t FROM '"'"'${PWD}/$$fn'"'"';\n";' \
	-e '}' ${GTT}/*.log >$@.tmp
	/bin/mv -f $@.tmp $@

load-tables.log: tables.sql

gong.log: gong.sql load-go.log
	psql -qaf $< | tee $@.tmp && /bin/mv $@.tmp $@

load-go.log: load-go.sql
	psql -qaf $< | tee $@.tmp && /bin/mv $@.tmp $@

load-go.sql: prep.sql schema.sql load.sql
	cat $^ >$@




.PHONY: clean cleaner cleanest
clean::
	/bin/rm -f *~ *.bak *.tmp
cleaner:: clean
	/bin/rm -f load-go.sql schema.sql load.sql
cleanest:: cleaner
	/bin/rm -f tables load-go.log gong.log
