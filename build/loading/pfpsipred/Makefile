default: update

include ../common.mk
include ../local.mk
include ../params.mk

N:=10
QNAME:=${SUBDIR}-r${PFPSIPRED_RUN_ID}
RUNSET1=runB-human
RUNSET2=pset1100
RUNSET=runset
NPER:=250
QPPN:=8
QTIME:=960:00:00
QUEUE:=dque

PFPSIPRED_RUN_ID:=`${PSQL_DCMD} "select preferred_run_id_by_pftype('PSIPRED')"`

${RUNSET}.ids: ${RUNSET1}.ids ${RUNSET2}.ids
	cat ${RUNSET1}.ids ${RUNSET2}.ids | sort -u -o $@

update: 
	make cleanest
	make done.ids ${RUNSET}.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N${N}
	make ${RUNSET}-todo-N${N}-qload

%.load: %.ids
	(PATH=.:${PATH} time -p run-pfpsipred -r ${PFPSIPRED_RUN_ID} < $<) >$@.err 2>&1
	/bin/mv -f $@.err $@

.done.ids:
	${PSQL} -Atc "select pseq_id from run_history where run_id=${PFPSIPRED_RUN_ID}" >$@
