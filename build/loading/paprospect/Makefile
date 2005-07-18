include ../common.mk

export PROSPECT_PATH:=/apps/compbio/i686-linux-2.4/opt/prospect

PARAMS_ID=1
PMODELSET_ID=10

%.load: %-M${PMODELSET_ID}.load;
%-M${PMODELSET_ID}.load: %.ids
	(time -p xargs -n25 <$< run-paprospect2 -p${PARAMS_ID} -M${PMODELSET_ID}) >$@.err 2>&1 \
	&& /bin/mv -f $@.err $@.log && touch $@



done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=1 and pmodelset_id=10' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@


