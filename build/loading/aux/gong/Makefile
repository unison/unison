# -*-Makefile-*-

default: gong.log

include ../../common.mk
include ../../local.mk
include ../../params.mk

gong.log: gong.sql
	psql -qaf $< | tee $@.tmp && /bin/mv $@.tmp $@

.PHONY: clean cleaner cleanest
clean::
	/bin/rm -f *~ *.bak *.tmp
cleaner:: clean
cleanest:: cleaner
	/bin/rm -f gong.log
