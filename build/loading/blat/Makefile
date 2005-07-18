include ../common.mk
PATH:=/usr/local/tools/bin:${PATH}
SHELL=bash

default all:
	@echo "no default target" 1>&2; exit 1

psls loads : %s : $(subst .fa,.%,$(wildcard *.fa))


.PRECIOUS: %.psl
%.psl: %.fa
	(time -p /usr/local/seq/bin/gfClient -minIdentity=80 -t=dnax -q=prot localhost 17701 /usr/seqdb2_nb/blat/nhgd $< $@.tmp) 2>$@.err \
	&& /bin/mv -f $@.tmp $@ && /bin/mv $@.err $@.log

%.load: %.psl
	(time -p load-blat -v --genasm_id=1 -Uloader -dcsb-dev $< >$@.tmp) 2>$@.err \
	&& /bin/mv -f $@.tmp $@ && /bin/mv $@.err $@.log



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
	psql -Atc 'select pseq_id from run_history where params_id=11' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@

.PHONY: start-gfServer
start-gfServer:
	(cd /usr/seqdb2_nb/blat/nhgd; \
	exec /usr/local/seq/bin/gfServer -mask -trans start trp.gene.com 17701 *.nib) >$@ 2>&1 &
