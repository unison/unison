default: update

include ../common.mk
include ../local.mk
include ../params.mk

update:
	make cleanest
	make done.ids runC-todo.ids
	make runC-todo.load

%.load: %.ids
	(time -p run-pfregexp <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@

.done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PFREGEXP_PARAMS_ID}' >$@
