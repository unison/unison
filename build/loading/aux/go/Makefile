# -*-Makefile-*-

update: go.log

include ../../common.mk
include ../../local.mk
include ../../params.mk

Y=2006
M=06
GTT=go_$Y$M-termdb-tables
TABLES_TAR_GZ:=${GO_DIR}/full/$Y-$M-01/${GTT}.tar.gz
MY2PG:=../../../sbin/my2pg.pl

test: ${GTT}-untar.log

# untar the "full" go tarball
.PRECIOUS: ${GTT}-untar.log
${GTT}-untar.log: ${TABLES_TAR_GZ}
	tar -xzf $< >$@.tmp 2>&1
	/bin/mv -f $@.tmp $@

.PHONY: sql
sql: ${GTT}.sql
${GTT}.sql: ${GTT}-untar.log
	perl -e 'while(my $$fn=shift) {' \
	-e 'my ($$t) = $$fn =~ m%(\w+)\.txt%;' \
	-e 'print "COPY go.$$t FROM '"'"'${PWD}/$$fn'"'"';\n";' \
	-e '}' ${GTT}/*.log >$@.tmp
	/bin/mv -f $@.tmp $@



# convert 
.PHONY: pgsql
pgsql: ${GTT}.pgsql
${GTT}/%.pgsql: ${GTT}/%.sql
	${MY2PG} $< >$@




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
	/bin/rm -fr go_200*
