include ../common.mk
include ../local.mk
include ../params.mk
PARAMS_ID:=6
SEQS_PER_RUN:=100
PATH:=/usr/local/seq/bin:${PATH}

default: runC.ids done.ids runC-todo.ids runC-todo.load

%.signalp: %.fa
	(time -p signalp -f short -t euk $<) >$@.tmp 2>$@.err
	/bin/mv -f $@.err $@.log; /bin/mv -f $@.tmp $@

%.load: %.ids
	(time -p xargs -n${SEQS_PER_RUN} run-pfsignalp <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PARAMS_ID}' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@
