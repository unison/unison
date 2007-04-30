default all: update

include ../common.mk
include ../local.mk
include ../params.mk

N:=10
QNAME=${SUBDIR}p${PAHMM_PARAMS_ID}
RUNSET=runC
NPER:=500


PAHMM_FS_PARAMS_ID:=52
PAHMM_LS_PARAMS_ID:=53


update: cleanest update-p${PAHMM_FS_PARAMS_ID} update-p${PAHMM_LS_PARAMS_ID}

update-p%:
	make ${RUNSET}.ids done-p$*.ids ${RUNSET}-p$*-todo.ids
	PAHMM_PARAMS_ID=$* make ${RUNSET}-p$*-todo-N$N ${RUNSET}-p$*-todo-N$N-qload

%.load: %.ids
	(time -p run-pahmm -N${NPER} -p${PAHMM_PARAMS_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

${RUNSET}-p%-todo.ids: ${RUNSET}.ids done-p%.ids
	comm -23 $^ >$@

.done-p%.ids:
	${PSQL} -UPUBLIC -Atc 'select pseq_id from run_history where params_id=$*' >$@
