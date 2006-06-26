default all: update

include ../common.mk
include ../local.mk
include ../params.mk

N:=5
QNAME=${SUBDIR}p${PAHMM_PARAMS_ID}
RUNSET=runB
NPER:=250


update:
	make cleanest
	make done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N${N}
	make ${RUNSET}-todo-N${N}-qload

%.load: %.ids
	(time -p run-pahmm -N${NPER} -p${PAHMM_PARAMS_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

.done.ids:
	${PSQL} -UPUBLIC -Atc 'select pseq_id from run_history where params_id=${PAHMM_PARAMS_ID} and origin_id=${PAHMM_ORIGIN_ID}' >$@
