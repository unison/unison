include ../common.mk
include ../local.mk
include ../params.mk

default: runC.ids done.ids runC-todo.ids runC-todo.load

run:
	make cleanest
	make runC-todo.ids runC-todo-N20
	make runC-todo-N20-qload

%.load: %.ids
	(PATH=.:${PATH} time -p run-pfssp_psipred -p ${PFSSP_PSIPRED_PARAMS_ID} < $<) >$@.err 2>&1
	/bin/mv -f $@.err $@

.done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PFSSP_PSIPRED_PARAMS_ID}' >$@
