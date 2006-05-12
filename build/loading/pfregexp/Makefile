default: update

include ../common.mk
include ../local.mk
include ../params.mk

QNAME=${SUBDIR}p${PFBIGPI_PARAMS_ID}
RUNSET=runB

update:
	make cleanest
	make done.ids ${RUNSET}-todo.ids
	make ${RUNSET}-todo.load

%-M11.load: %.ids
	(time -p run-pfregexp -M11 <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@

.done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PFREGEXP_PARAMS_ID}' >$@
