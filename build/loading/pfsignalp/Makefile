include ../common.mk

PARAMS_ID:=6
PATH:=/usr/local/seq/bin:${PATH}

default:
	@echo no $@ target; exit 1


%.signalp: %.fa
	(time -p signalp -f short -t euk $<) >$@.tmp 2>$@.err
	/bin/mv -f $@.err $@.log; /bin/mv -f $@.tmp $@

%.load: %.ids
	(time -p xargs -n50 run-pfsignalp <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PARAMS_ID}' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@
