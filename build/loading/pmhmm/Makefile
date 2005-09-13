include ../common.mk
include ../local.mk
include ../params.mk

export PGUSER:=unison

default: Pfam_fs.load Pfam_ls.load

Pfam_ls.load Pfam_fs.load: %.load: ${PFAM_DIR}/%.gz
	load-pmhmm $< >$@.err 2>&1
	/bin/mv -f $@.err $@
