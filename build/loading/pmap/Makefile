default: update

include ../common.mk
include ../local.mk
include ../params.mk

PMAP_RUN_ID:=`${PSQL_DCMD} "select preferred_run_id_by_pftype('PMAP')"`

RUNSET=runC-human

PATH:=/gne/research/apps/gmap/current/x86_64-linux-2.6/bin:${PATH}
SHELL=bash
CMDLINE:=$(shell ${PSQL_DCMD} "select replace(p.commandline,'%s','') from params p join run r on r.params_id=p.params_id where r.run_id=${PMAP_RUN_ID}")
QPPN:=2
N:=5

update:
	make cleanest
	make done.ids ${RUNSET}.ids ${RUNSET}-todo.ids
	make ${RUNSET}-todo-N${N}-qload

.PRECIOUS: %.psl
%.psl: %.fa
	(time -p ${CMDLINE} $< >$@.tmp) 2>$@.err
	/bin/mv -f $@.tmp $@ && /bin/mv $@.err $@.log

%.load: %.psl
	(time -p load-pmap -r ${PMAP_RUN_ID} -v --genasm_id=${PMAP_GENASM_ID} $<) >$@.err 2>&1
	/bin/mv $@.err $@

.done.ids:
	${PSQL_DCMD} "select pseq_id from run_history where run_id=${PMAP_RUN_ID}" >$@

cleanest::
	/bin/rm -f *.psl
