default: update

include ../../loading/common.mk
include ../../loading/local.mk
include ../../loading/params.mk

GVOPTS:=-Goverlap=false

update: $(foreach t,dot neato twopi fdp,${PGDATABASE}-$t.ps)

%.log:
	postgresql_autodoc -d $* -u PUBLIC -s unison >$@.tmp 2>&1
	/bin/mv $@.tmp $@

%.dot: %.log;
%.neato: %.log;

%-dot.ps: %.dot
	dot -Tps ${GVOPTS} -o $@ $<
%-neato.ps: %.neato
	neato -Tps ${GVOPTS} -o $@ $<
%-twopi.ps: %.neato
	twopi -Tps ${GVOPTS} -o $@ $<
%-fdp.ps: %.neato
	fdp -Tps ${GVOPTS} -o $@ $<
