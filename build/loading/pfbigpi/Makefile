include ../common.mk

PARAMS_ID:=19

default:
	@echo no $@ target; exit 1


%.load: %.ids
	(time -p run-pfbigpi -p${PARAMS_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PARAMS_ID}' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@
