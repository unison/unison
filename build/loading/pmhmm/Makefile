include ../common.mk
include ../local.mk
include ../params.mk

export PGUSER:=unison

default: Pfam_fs.load Pfam_ls.load

Pfam_ls.load Pfam_fs.load: %.load: ${PFAM_DIR}/%.gz
	load-pmhmm $< >$@.err 2>&1
	/bin/mv -f $@.err $@

Pfam_upgrade.log: Pfam_ls.load Pfam_fs.load
	${PSQL_VCMD} 'insert into pmsm_pmhmm select * from _pmsm_pmhmm_pfam_upgrade' >$@.err 2>&1
	/bin/mv -f $@.err $@
