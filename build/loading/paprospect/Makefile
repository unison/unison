include ../common.mk
PARAMS_ID:=1
PMODELSET_ID:=10
export PROSPECT_PATH:=/gne/compbio/i686-linux-2.6/opt/prospect

default: runA.ids done.ids runA-todo.ids runA-todo.load

%.load: %-M${PMODELSET_ID}.load;
%-M${PMODELSET_ID}.load: %.ids
	(time -p xargs -n25 <$< run-paprospect2 -p${PARAMS_ID} -M${PMODELSET_ID}) >$@.err 2>&1 \
	&& /bin/mv -f $@.err $@.log && touch $@

.done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=1 and pmodelset_id=10' >$@.tmp
	/bin/mv -f $@.tmp $@


