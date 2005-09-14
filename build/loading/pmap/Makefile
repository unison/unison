include ../common.mk
PATH:=/usr/local/tools/bin:/usr/local/seq/bin/:${PATH}
SHELL=bash

default all:
	@echo "no default target" 1>&2; exit 1

psls loads : %s : $(subst .fa,.%,$(wildcard *.fa))

PARAMS:=PMAP
CMDLINE=$(shell psql -h csb -d csb-dev -Atc "select commandline from params where name='${PARAMS}'")

.PRECIOUS: %.psl
%.psl: %.fa
	(time -p ${CMDLINE} $< >>$@.tmp) 2>>$@.err \
	&& /bin/mv -f $@.tmp $@ && /bin/mv $@.err $@.log

%.load: %.psl
	(time -p load-pmap -p ${PARAMS} -v -Uloader -dcsb-dev $< >$@.tmp) 2>$@.err \
	&& /bin/mv -f $@.tmp $@ && /bin/mv $@.err $@.log

# load psl files (run on cluster)
# eg$ make todo.load.log
%.qload.log: % FORCE
	for f in $</${PREFIX}*.psl; do echo qsub/$${f%psl}load; done | xargs -t make >|$@.err 2>&1
	/bin/mv -f $@.err $@

# make psl files (run on geneland)
# eg$ make todo.psl.log
%.psl.log: % FORCE
	for f in $</${PREFIX}*.ids; do echo $${f%ids}psl; done | xargs -tn1 make >|$@.err 2>&1 
	/bin/mv -f $@.err $@

# load psl files (run on cluster)
# eg$ make todo.load.log
%.load.log: % FORCE
	for f in $</${PREFIX}*.psl; do echo $${f%psl}load; done | xargs -t make >|$@.err 2>&1 
	/bin/mv -f $@.err $@

done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=25' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@
