include ../common.mk
include ../local.mk
include ../params.mk

default:
	@echo no $@ target; exit 1

%.load: %.ids
	(time -p run-pftmdetect --params_id=9 <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=9' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@
