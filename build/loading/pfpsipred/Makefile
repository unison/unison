include ../common.mk
include ../local.mk
include ../params.mk

N:=20
QNAME=${SUBDIR}p${PAHMM_PARAMS_ID}
RUNSET=runB
NPER:=250

default:
	@echo no $@ target; exit 1

run:
	make cleanest
	make done.ids ${RUNSET}.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N${N}
	make ${RUNSET}-todo-N${N}-qload

%.load: %.ids
	(PATH=.:${PATH} time -p run-pfpsipred -p ${PFPSIPRED_PARAMS_ID} < $<) >$@.err 2>&1
	/bin/mv -f $@.err $@

.done.ids:
	${PSQL} -UPUBLIC -Atc 'select pseq_id from run_history where params_id=${PFPSIPRED_PARAMS_ID}' >$@
