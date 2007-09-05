include ../common.mk
include ../local.mk
include ../params.mk

export PGUSER:=unison

PMHMM_DATA_DIR:=${UNISON_HOME}/runtime/data/pmhmm
PFAM_VERSION:=`ls ${PFAM_DIR}/version_*.gz | grep -o "[[:digit:]]\{2,\}.[[:digit:]]"`

default: Pfam_fs.load Pfam_ls.load

.PRECIOUS: ${PMHMM_DATA_DIR}/%.gz
Pfam_ls.load Pfam_fs.load: %.load: ${PMHMM_DATA_DIR}/%.gz
	load-pmhmm -V ${PFAM_VERSION} --deprecate ${PMHMM_DATA_DIR}/$*.gz >$@.err 2>&1
	/bin/mv -f $@.err $@

${PMHMM_DATA_DIR}/%.gz: 
	cp ${PFAM_DIR}/$*.* ${PMHMM_DATA_DIR}

Pfam_upgrade.log: Pfam_ls.load Pfam_fs.load
	${PSQL_VCMD} 'insert into pmsm_pmhmm select * from _pmsm_pmhmm_pfam_upgrade' >$@.err 2>&1
	/bin/mv -f $@.err $@

cleanest::
	/bin/rm -f ${PMHMM_DATA_DIR}/*.gz ${PMHMM_DATA_DIR}/*.hmmb ${PMHMM_DATA_DIR}/*.hmmb.ssi
