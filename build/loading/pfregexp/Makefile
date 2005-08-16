include ../common.mk
PARAMS_ID:=12
PMODELSET_ID:=11


default: runC.ids done.ids runC-todo.ids runC-todo.load

%.load: %.ids
	(time -p run-pfregexp -M${PMODELSET_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

.done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PARAMS_ID} and pmodelset_id=${PMODELSET_ID}' >$@.tmp
	/bin/mv -f $@.tmp $@
