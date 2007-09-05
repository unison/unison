default all: update

include ../common.mk
include ../local.mk
include ../params.mk

PFSEG_RUN_ID:=`${PSQL_DCMD} "select preferred_run_id_by_pftype('seg')"`

N:=5
QNAME:=${SUBDIR}-r${PFSEG_RUN_ID}
RUNSET:=runC
NPER:=250

update:
	make cleaner
	make ${RUNSET}.ids done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N${N}
	make ${RUNSET}-todo-N${N}-qload

.PRECIOUS: %.load

%.load: %.ids
	(time -p run-pfseg -N${NPER} -r${PFSEG_RUN_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

.done.ids:
	${PSQL} -Atc "select pseq_id from run_history where run_id=${PFSEG_RUN_ID}" >$@

