include ../defaults.mk

PATH:=${COMPBIO_EPREFIX}/bin:${PATH}

PARAMS_ID:=20

default:
	@echo no $@ target; exit 1

%.load: %.protcomp
	(time -p load-psprotcomp <$<) >$@.err 2>&1
	/bin/mv -f $@.err $@.log; touch $@

%.protcomp: %.fa
#	(time -p protcomp $< >$@.tmp) 2>$@.err
	protcomp $< >$@.tmp
	/bin/mv -f $@.tmp $@

done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=20' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@
