default: update

include ../common.mk
include ../local.mk
include ../params.mk

PSIPRED_PATH:=${UNISON_HOME}/loading/pfpsipred/

export PSIPRED_PATH

PAPROSPECT_RUN_ID:=`${PSQL_DCMD} "select preferred_run_id_by_pftype('Prospect')"`

N:=5
QNAME=${SUBDIR}-r${PAPROSPECT_RUN_ID}
QPPN:=2
RUNSET=runA-human

update:
	make cleanest
	make ${RUNSET}.ids done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N${N}
	make ${RUNSET}-todo-N${N}-qload

%.load: %.ids
	(time -p xargs -n10 <$< run-paprospect -r${PAPROSPECT_RUN_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

.done.ids:
	${PSQL_DCMD} "select pseq_id from run_history where run_id=${PAPROSPECT_RUN_ID}" >$@
