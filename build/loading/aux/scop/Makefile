include ../../local.mk
include ../../common.mk
include ../../params.mk

default all: update

update: scop.load


SCOP_DIR:=${RESEARCH_PREFIX}/data/public/scop/parse
SCOP_VERSION:=1.69
CLA:=${SCOP_DIR}/dir.cla.scop.txt_${SCOP_VERSION}
#COM:=${SCOP_DIR}/dir.com.scop.txt_${SCOP_VERSION}
DES:=${SCOP_DIR}/dir.des.scop.txt_${SCOP_VERSION}
HIE:=${SCOP_DIR}/dir.hie.scop.txt_${SCOP_VERSION}


update default all: ${CLA} ${DES} ${HIE} scop.load

.PRECIOUS: scop.sql
scop.sql:
	./scop2sql --cla ${CLA} --des ${DES} --hie ${HIE} >$@ 2>$@.log

scop.load: scop.sql FORCE
	psql -f $< 2>&1 | tee $@.err
	/bin/mv $@.err $@

cleanest::
	/bin/rm scop.sql
