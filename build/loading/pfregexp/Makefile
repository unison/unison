default: update

include ../common.mk
include ../local.mk
include ../params.mk

QNAME=${SUBDIR}p${PFREGEXP_PARAMS_ID}
RUNSET=runB

update:
	make cleanest
	make done.ids ${RUNSET}-todo.ids
	make ${RUNSET}-todo.load

%.load: %.ids
	(time -p run-pfregexp -M${PMREGEXP_PMODELSET_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@

.done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PFREGEXP_PARAMS_ID} and pmodelset_id=${PMREGEXP_PMODELSET_ID}' >$@
