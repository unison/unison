default: update

include ../common.mk
include ../local.mk
include ../params.mk

N:=5
QNAME=${SUBDIR}p${PFTMDETECT_PARAMS_ID}
RUNSET=runC
NPER:=250

update:
	make cleanest
	make done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N$N
	make ${RUNSET}-todo-N$N-qload

%.load: %.ids
	(time -p run-pftmdetect --params_id=9 <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

.done.ids:
	${PSQL} -Atc 'select pseq_id from run_history where params_id=${PFTMDETECT_PARAMS_ID}' >$@
