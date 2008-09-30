include ../../local.mk
include ../../common.mk
include ../../params.mk

PTM_LIST:=${UNIPROT_DIR}/docs/ptmlist.txt

UNIPROT_SP_DAT:=${UNIPROT_DIR}/uniprot_sprot.dat.gz

update default all: ptm-list.load ptm.load

ptm-list.sql: ${PTM_LIST}
	./load-ptmlist  $< > $@.err 2>&1
	/bin/mv -f $@.err $@

ptm.sql: ${UNIPROT_SP_DAT}
	gzip -cdq $< | ./load-ptm > $@.err 2>&1
	/bin/mv -f $@.err $@

%.load: %.sql
	(time -p ${PSQL} -qf $<) >$@.err 2>&1
	/bin/mv -f $@.err $@

cleanest::
	/bin/rm ptm.sql
