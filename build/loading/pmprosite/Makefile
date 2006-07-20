include ../common.mk
include ../local.mk
include ../params.mk

default: Prosite.load

Prosite.load:
	load-pmprosite -v -o ${PROSITE_ORIGIN} $< >$@.err 2>&1
	/bin/mv -f $@.err $@
