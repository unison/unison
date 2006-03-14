default: update

include ../common.mk
include ../local.mk
include ../params.mk

N:=5
QNAME=${SUBDIR}p${PSPROTCOMP_PARAMS_ID}
RUNSET=runC-human
NPER:=250


update:
	make cleanest
	make done.ids ${RUNSET}.ids ${RUNSET}-todo.ids
	make ${RUNSET}-todo-N${N}-qload

%.load: %.ids
	(time -p run-psprotcomp -v -N${PSPROTCOMP_SEQS_PER_RUN} <$<) >$@.err 2>&1
	/bin/mv -f $@.err $@

.done.ids:
	${PSQL_DCMD} 'select pseq_id from run_history where params_id=${PSPROTCOMP_PARAMS_ID}' >$@.tmp
	/bin/mv -f $@.tmp $@
