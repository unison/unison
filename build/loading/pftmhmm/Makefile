default: update

include ../common.mk
include ../local.mk
include ../params.mk

PFTMHMM_RUN_ID:=`${PSQL_DCMD} "select preferred_run_id_by_pftype('TMHMM')"`

N:=5
QNAME=${SUBDIR}-r${PFTMHMM_RUN_ID}
RUNSET1=runC
RUNSET2=pset1100
RUNSET=runset
NPER:=250

${RUNSET}.ids: ${RUNSET1}.ids ${RUNSET2}.ids
	cat ${RUNSET1}.ids ${RUNSET2}.ids | sort -u -o $@

update:
	make cleanest
	make ${RUNSET}.ids done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N$N
	make ${RUNSET}-todo-N$N-qload

%.load: %.ids
	(time -p run-pftmhmm -r ${PFTMHMM_RUN_ID} < $<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

.done.ids:
	${PSQL} -Atc "select pseq_id from run_history where run_id=${PFTMHMM_RUN_ID}" >$@

