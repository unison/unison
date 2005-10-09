include ../common.mk
include ../local.mk
include ../params.mk

default: runA.ids done.ids runA-todo.ids runA-todo.load

run:
	make cleanest
	make done.ids runA-todo.ids runA-todo-N5
	make runA-todo-N5-qload

%.load: %-M${PAPROSPECT_PMODELSET_ID}.load;
%-M${PAPROSPECT_PMODELSET_ID}.load: %.ids
	(time -p xargs -n10 <$< run-paprospect2 -p${PAPROSPECT_PARAMS_ID} -M${PAPROSPECT_PMODELSET_ID}) >$@.err 2>&1
	/bin/mv -f $@.err $@

.done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PAPROSPECT_PARAMS_ID} and pmodelset_id=${PAPROSPECT_PMODELSET_ID}' >$@
