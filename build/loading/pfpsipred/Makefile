default: update

include ../common.mk
include ../local.mk
include ../params.mk

N:=5
QNAME=${SUBDIR}p${PFPSIPRED_PARAMS_ID}
RUNSET=runB-human
NPER:=250

update:
	make cleanest
	make done.ids ${RUNSET}.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N${N}
	make ${RUNSET}-todo-N${N}-qload

%.load: %.ids
	(PATH=.:${PATH} time -p run-pfpsipred -p ${PFPSIPRED_PARAMS_ID} < $<) >$@.err 2>&1
	/bin/mv -f $@.err $@

.done.ids:
	${PSQL} -UPUBLIC -Atc 'select pseq_id from run_history where params_id=${PFPSIPRED_PARAMS_ID}' >$@
