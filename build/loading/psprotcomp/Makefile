include ../defaults.mk

PATH:=${COMPBIO_EPREFIX}/bin:${PATH}

PARAMS_ID:=20


#ifneq '$(shell uname -s)' 'OSF1'
# uname -s == OSF1 is a surrogate for whether we're on geneland
#$(error protcomp must be run on geneland)
#endif


default:
	@echo no $@ target; exit 1

%.load: %.protcomp
	(time -p load-psprotcomp <$<) >$@.err 2>&1
	/bin/mv -f $@.err $@.log; touch $@

.PRECIOUS: %.protcomp
%.protcomp: %.fa
#	(time -p protcomp $< >$@.tmp) 2>$@.err
	protcomp $< >$@.tmp
	/bin/mv -f $@.tmp $@

done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=20' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@
