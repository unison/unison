include ../common.mk
include ../local.mk
include ../params.mk

N:=10
QNAME=${SUBDIR}p${PFTMHMM_PARAMS_ID}
RUNSET=runC
NPER:=250

default:
	@echo no $@ target; exit 1

run:
	make cleanest
	make done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N$N
	make ${RUNSET}-todo-N$N-qload

%.load: %.ids
	(time -p run-pftmhmm -p ${PFTMHMM_PARAMS_ID} < $<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

.done.ids:
	${PSQL} -UPUBLIC -Atc 'select pseq_id from run_history where params_id=${PFTMHMM_PARAMS_ID}' >$@

