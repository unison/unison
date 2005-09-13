include ../common.mk
include ../local.mk
include ../params.mk


default:
	@echo no $@ target; exit 1

run:
	make cleanest
	make done.ids runC-todo.ids runC-todo-N20
	make runC-todo-N20-qload


%.load: %.ids
	(time -p run-pahmm -N250 -p${PAHMM_PARAMS_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

.done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PAHMM_PARAMS_ID}' >$@
