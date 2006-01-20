default: update

include ../common.mk
include ../local.mk
include ../params.mk

N:=5
QNAME=${SUBDIR}p${PFBIGPI_PARAMS_ID}
RUNSET=runC

default:
	@echo no $@ target; exit 1

update:
	make cleanest
	make done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N${N}
	make ${RUNSET}-todo-N${N}-qload

%.load: %.ids
	(time -p run-pfbigpi -v -p${PFBIGPI_PARAMS_ID} <$<) >$@.err 2>&1
	/bin/mv -f $@.err $@

.done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PFBIGPI_PARAMS_ID}' >$@
