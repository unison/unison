include ../common.mk
include ../local.mk
include ../params.mk



PATH:=/usr/local/tools/bin:/usr/local/seq/bin/:${PATH}
SHELL=bash

default all:
	@echo "no default target" 1>&2; exit 1

PARAMS:=PMAP
CMDLINE=$(shell psql -h csb -d csb-dev -Atc "select commandline from params where name='${PARAMS}'")

.PRECIOUS: %.psl
%.psl: %.fa
	(time -p ${CMDLINE} $< >>$@.tmp) 2>>$@.err \
	&& /bin/mv -f $@.tmp $@ && /bin/mv $@.err $@.log

%.load: %.psl
	(time -p load-pmap -p ${PARAMS} -v --genasm_id=2 $< >$@.tmp) 2>$@.err \
	&& /bin/mv -f $@.tmp $@ && /bin/mv $@.err $@.log

# eg$ make todo-psl
%-psl: % FORCE
	@for f in $*/${PATTERN}.ids; do echo "$${f%ids}psl"; done | tr \\012 \\0 | xargs -0rt ${MAKE} $J

# make psl files (run on geneland)
# eg$ make todo-qpsl
%-qpsl: % FORCE
	@for f in $*/${PATTERN}.ids; do echo "qsub/$${f%ids}psl"; done | tr \\012 \\0 | xargs -0rt ${MAKE} $J

done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PMAP_PARAMS_ID}' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@
