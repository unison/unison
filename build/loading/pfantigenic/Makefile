default: update

include ../common.mk
include ../local.mk
include ../params.mk

N:=5
QNAME:=${SUBDIR}-r${PFANTIGENIC_RUN_ID}
RUNSET=runC-human
NPER:=250

PFANTIGENIC_RUN_ID:=`${PSQL_DCMD} "select preferred_run_id_by_pftype('EMBOSS/antigenic')"`

update:
	make cleanest
	make done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N${N}
	make ${RUNSET}-todo-N${N}-qload

%.load: %.ids
	(time -p xargs -n1000 run-pfantigenic <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

.done.ids:
	${PSQL} -UPUBLIC -Atc 'select pseq_id from run_history where params_id=${PFANTIGENIC_PARAMS_ID}' >$@
