default all: update

include ../common.mk
include ../local.mk
include ../params.mk

N:=10
QNAME:=${SUBDIR}-r${PAHMM_RUN_ID}
QPPN:=8
RUNSET=runC
NPER:=500

PFAM_FS_RUN_ID:=45
PFAM_LS_RUN_ID:=46

update: cleanest update-r${PFAM_FS_RUN_ID} update-r${PFAM_LS_RUN_ID}

update-r%:
	make ${RUNSET}.ids done-r$*.ids ${RUNSET}-r$*-todo.ids
	PAHMM_RUN_ID=$* make ${RUNSET}-r$*-todo-N$N ${RUNSET}-r$*-todo-N$N-qload

%.load: %.ids
	(time -p run-pahmm -N${NPER} -r${PAHMM_RUN_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

${RUNSET}-r%-todo.ids: ${RUNSET}.ids done-r%.ids
	comm -23 $^ >$@

.done-r%.ids:
	${PSQL} -Atc 'select pseq_id from run_history where run_id=$*' >$@
