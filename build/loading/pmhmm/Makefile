include ../defaults.mk

vpath % ${COMPBIO}/share

default:
	@echo no $@ target -- e.g., make pfam-14.0/Pfam_fs.load ; exit 1

%.load: %
	@mkdir -p "${@D}"
	load-pmhmm $< >$@.err 2>&1
	/bin/mv -f $@.err $@.log; touch $@
