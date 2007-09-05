default: update

include ../common.mk
include ../local.mk
include ../params.mk

N:=5
QNAME:=${SUBDIR}-r${PSPROTCOMP_RUN_ID}
RUNSET=runC-human
PSPROTCOMP_SEQS_PER_RUN:=250

PSPROTCOMP_RUN_ID:=`${PSQL_DCMD} "select preferred_run_id_by_pftype('Protcomp')"`

update:
	make cleanest
	make done.ids ${RUNSET}.ids ${RUNSET}-todo.ids
	make ${RUNSET}-todo-N${N}-qload

%.load: %.ids
	(time -p run-psprotcomp -v -N${PSPROTCOMP_SEQS_PER_RUN}  -r ${PSPROTCOMP_RUN_ID} <$<) >$@.err 2>&1
	/bin/mv -f $@.err $@

.done.ids:
	${PSQL} -Atc "select pseq_id from run_history where run_id=${PSPROTCOMP_RUN_ID}" >$@.tmp
	/bin/mv -f $@.tmp $@
