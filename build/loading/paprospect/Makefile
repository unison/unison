default: update

include ../common.mk
include ../local.mk
include ../params.mk

N:=5
QNAME=${SUBDIR}p${PAPROSPECT_PARAMS_ID}
RUNSET=runB


update:
	make cleanest
	make done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N${N}
	make ${RUNSET}-todo-N${N}-qload

%.load: %-M${PAPROSPECT_PMODELSET_ID}.load;
%-M${PAPROSPECT_PMODELSET_ID}.load: %.ids
	(time -p xargs -n10 <$< run-paprospect -p${PAPROSPECT_PARAMS_ID} -M${PAPROSPECT_PMODELSET_ID}) >$@.err 2>&1
	/bin/mv -f $@.err $@

.done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PAPROSPECT_PARAMS_ID} and pmodelset_id=${PAPROSPECT_PMODELSET_ID}' >$@
