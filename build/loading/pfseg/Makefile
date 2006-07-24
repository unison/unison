default all: update

include ../common.mk
include ../local.mk
include ../params.mk

N:=5
QNAME=${SUBDIR}p${PFSEG_PARAMS_ID}
RUNSET=runC
CMDLINE:=$(shell ${PSQL_DCMD} 'select commandline from params where params_id=${PFSEG_PARAMS_ID}')
NPER:=250

update:
	make cleaner
	make done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N${N}
	make ${RUNSET}-todo-N${N}-qload

.PRECIOUS: %.load

%.load: %.ids
	(time -p run-pfseg -N${NPER} -p${PFSEG_PARAMS_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

.done.ids:
	${PSQL} -UPUBLIC -Atc 'select pseq_id from run_history where params_id=${PFSEG_PARAMS_ID}' >$@

