default: update

include ../common.mk
include ../local.mk
include ../params.mk

N:=5
RUNSET=runC-human

PATH:=/usr/local/tools/bin:/usr/local/seq/bin/:${PATH}
SHELL=bash
CMDLINE:=$(shell ${PSQL_DCMD} 'select commandline from params where params_id=${PMAP_PARAMS_ID}')


update:
	make cleanest
	make done.ids ${RUNSET}-todo.ids
	make ${RUNSET}-todo.load


.PRECIOUS: %.psl
%.psl: %.fa
	(time -p ${CMDLINE} $< >>$@.tmp) 2>>$@.err \
	&& /bin/mv -f $@.tmp $@ && /bin/mv $@.err $@.log

%.load: %.psl
	(time -p load-pmap -p ${PMAP_PARAMS_ID} -v --genasm_id=2 $<) >$@.err 2>&1
	/bin/mv $@.err $@

.done.ids:
	${PSQL_DCMD} 'select pseq_id from run_history where params_id=${PMAP_PARAMS_ID}' >$@


# eg$ make todo-psl
%-psl: % FORCE
	@for f in $*/${PATTERN}.ids; do echo "$${f%ids}psl"; done | tr \\012 \\0 | xargs -0rt ${MAKE} $J

# make psl files (run on geneland)
# eg$ make todo-qpsl
%-qpsl: % FORCE
	@for f in $*/${PATTERN}.ids; do echo "qsub/$${f%ids}psl"; done | tr \\012 \\0 | xargs -0rt ${MAKE} $J

