include ../common.mk

PARAMS_ID:=12
PMODELSET_ID:=11

default:
	@echo no $@ target; exit 1


%.load: %.ids
	(time -p run-pfregexp -M${PMODELSET_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@


done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PARAMS_ID} and pmodelset_id=${PMODELSET_ID}' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@
