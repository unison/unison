default: update

include ../common.mk
include ../local.mk
include ../params.mk

PFREGEXP_RUN_ID:=`${PSQL_DCMD} "select preferred_run_id_by_pftype('regexp')"`

N:=5
QNAME=${SUBDIR}-r${PFREGEXP_RUN_ID}
RUNSET=runB

update:
	make cleanest
	make done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N${N}
	make ${RUNSET}-todo-N${N}-qload

%.load: %.ids
	(time -p run-pfregexp -r ${PFREGEXP_RUN_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

.done.ids:
	${PSQL_DCMD} "select pseq_id from run_history where run_id=${PFREGEXP_RUN_ID}" >$@
