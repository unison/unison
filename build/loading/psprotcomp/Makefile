default: update

include ../common.mk
include ../local.mk
include ../params.mk

N:=5
QNAME=${SUBDIR}p${PSPROTCOMP_PARAMS_ID}
RUNSET=runB
NPER:=250


update:
	make cleanest
	make done.ids ${RUNSET}-todo.ids
	make ${RUNSET}-todo.load


ifeq '$(shell uname -s)' 'OSF1'
# uname -s == OSF1 is a surrogate for whether we're on a geneland node
%.load: %.ids
	(time -p run-psprotcomp -v -N${PSPROTCOMP_SEQS_PER_RUN} <$<) >$@.err 2>&1
	/bin/mv -f $@.err $@
else
%.load: %.ids
	@echo ERROR: protcomp must be run on geneland; exit 1
endif


.done.ids:
	${PSQL_DCMD} 'select pseq_id from run_history where params_id=${PSPROTCOMP_PARAMS_ID}' >$@.tmp
	/bin/mv -f $@.tmp $@
