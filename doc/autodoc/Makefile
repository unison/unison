default: update

PGDATABASE=csb

GVOPTS:=-Goverlap=false

update: $(foreach t,dot neato twopi fdp,${PGDATABASE}-$t.ps)

%.log:
	postgresql_autodoc -h localhost -d $* -u PUBLIC -s unison >$@.tmp 2>&1
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


clean::
cleaner:: clean
cleanest:: cleaner
	/bin/rm *.ps *.html *.dia *.xml
