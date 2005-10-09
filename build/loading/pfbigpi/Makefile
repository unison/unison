include ../common.mk
include ../local.mk
include ../params.mk

default:
	@echo no $@ target; exit 1

run:
	make cleanest
	make done.ids runC-todo.ids runC-todo-N5
	make runC-todo-N5-qload

%.load: %.ids
	(time -p run-pfbigpi -v -p${PFBIGPI_PARAMS_ID} <$<) >$@.err 2>&1
	/bin/mv -f $@.err $@

.done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PFBIGPI_PARAMS_ID}' >$@
