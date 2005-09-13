default: runC-todo.load

include ../common.mk
include ../local.mk
include ../params.mk
PARAMS_ID:=19


%.load: %.ids
	(time -p run-pfbigpi -v -p${PARAMS_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

.done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PARAMS_ID}' >$@.tmp
	/bin/mv -f $@.tmp $@
