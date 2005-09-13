include ../common.mk
include ../local.mk
include ../params.mk

PARAMS_ID=24
PSET_ID=62

default:
	@echo no $@ target; exit 1

%: %.ids
	(time -p run-pftmhmm -p ${PARAMS_ID} < $<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PARAMS_ID}' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@
