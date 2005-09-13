include ../common.mk
include ../local.mk
include ../params.mk

default:
	@echo no $@ target; exit 1

run:
	make cleanest
	make done.ids runC-todo.ids
	make runC-todo.load

%.load: %.ids
	(time -p run-pfregexp -M${ITxM_PMODELSET_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@

.done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PFREGEXP_PARAMS_ID} and pmodelset_id=${ITxM_PMODELSET_ID}' >$@
