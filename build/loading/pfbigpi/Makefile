default: update

include ../common.mk
include ../local.mk
include ../params.mk

PFBIGPI_RUN_ID:=`${PSQL_DCMD} "select preferred_run_id_by_pftype('BIG-PI')"`

N:=5
QNAME=${SUBDIR}-r${PFBIGPI_RUN_ID}
RUNSET=runB

default:
	@echo no $@ target; exit 1

update:
	make cleanest
	make ${RUNSET}.ids done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N${N}
	make ${RUNSET}-todo-N${N}-qload

%.load: %.ids
	(time -p run-pfbigpi -v -r${PFBIGPI_RUN_ID} <$<) >$@.err 2>&1
	/bin/mv -f $@.err $@

.done.ids:
	psql -Atc "select pseq_id from run_history where run_id=${PFBIGPI_RUN_ID}" >$@
