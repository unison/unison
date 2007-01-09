include ../../common.mk
include ../../local.mk
include ../../params.mk

TABLES:=cytoband
GENASM:=hg18
UCSC_CYTOBAND_URL:=http://hgdownload.cse.ucsc.edu/goldenPath/${GENASM}/database/cytoBand.txt.gz

export PGUSER=unison
_:=$(shell mkdir -p logs)

default all: update

update: $(foreach t,${TABLES},logs/$t-load.log)

cytoband.dat: FORCE
	wget -nv -O$@.gz "${UCSC_CYTOBAND_URL}"
	gzip -cdq $@.gz > $@

$(foreach t,${TABLES},logs/$t-create.log): logs/%.log: sql/%.sql
	-psql -Xf $< 2>&1 | tee $@

$(foreach t,${TABLES},logs/$t-load.log): logs/%-load.log: %.dat FORCE
	cat $< | ${PSQL} -f sql/$*-load.sql | tee $@.err
	/bin/mv -f $@.err $@

cleanest::
	/bin/rm -fr cytoband.dat logs
