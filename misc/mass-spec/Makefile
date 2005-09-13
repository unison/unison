## mass-spec/Makefile -- build sequences databases for mass spec

.SUFFIXES:
.PHONY: FORCE
.DELETE_ON_ERROR:

DATE=$(shell date +%Y%m%d)
PSET=uniC


default: ${PSET}-${DATE}.fa.gz ${PSET}-rev-${DATE}.fa.gz


%-rev-${DATE}.fa: %-${DATE}.fa
	./seq-reverse <$< >$@

%-${DATE}.fa:
	get-seq -UPUBLIC -B -S -v $* >$@

%.gz: %
	gzip -cq <$< >$@
