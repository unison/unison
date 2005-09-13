include ../common.mk
include ../local.mk
include ../params.mk

default: runC.ids done.ids runC-todo.ids runC-todo.load


ifeq '$(shell uname -s)' 'OSF1'
# uname -s == OSF1 is a surrogate for whether we're on a geneland node
PATH:=${COMPBIO_EPREFIX}/bin:${PATH}
%.load: %.ids
	(time -p run-psprotcomp -N${PSPROTCOMP_SEQS_PER_RUN} <$<) >$@.err 2>&1
	/bin/mv -f $@.err $@
else
%.load: %.ids
	@echo ERROR: protcomp must be run on geneland; exit 1
endif


.done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PSPROTCOMP_PARAMS_ID}' >$@.tmp
	/bin/mv -f $@.tmp $@
