default: update

include ../common.mk
include ../local.mk
include ../params.mk

RUN_ID:=`${PSQL_DCMD} "select preferred_run_id_by_pftype('netphos')"`

N:=5
QNAME=${SUBDIR}-r${RUN_ID}
RUNSET=runC
NPER:=250

update:
	make cleanest
	make ${RUNSET}.ids done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N$N
	make ${RUNSET}-todo-N$N-qload

%.load: %.ids
	(time -p run-pfnetphos -v -r ${RUN_ID} < $<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

.done.ids:
	${PSQL} -Atc "select pseq_id from run_history where run_id=${RUN_ID}" >$@

