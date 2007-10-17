default: update

include ../common.mk
include ../local.mk
include ../params.mk


PFSIGNALP_RUN_ID:=`${PSQL_DCMD} "select preferred_run_id_by_pftype('SignalP')"`

N:=5
QNAME:=${SUBDIR}-r${PFSIGNALP_RUN_ID}
RUNSET:=runC
NPER:=100


update:
	make cleanest
	make ${RUNSET}.ids done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N$N
	make ${RUNSET}-todo-N$N-qload

%.load: %.ids
	(time -p xargs -n${NPER} run-pfsignalp -r${PFSIGNALP_RUN_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

.done.ids:
	psql -Atc "select pseq_id from run_history where run_id=${PFSIGNALP_RUN_ID}" >$@
