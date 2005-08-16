include ../common.mk
PARAMS_ID:=3
DB:=uniblast

default: runC-todo-${DB}.load;


.PHONY: setup
setup: ${DB}.phr

${DB}.ids:
	${PSQL_DCMD} "select pseq_id from pseqset where pset_id=pset_id('BLAST DB')" >$@.tmp
	/bin/mv -f $@.tmp $@

.PRECIOUS: %.phr
%.phr: %.fa
	formatdb -t "$* `date +'%Y-%m-%d %H:%M'`" -l $@.log -pT -n tmp-$* -i $<
	for f in $*.phr $*.pin $*.psq; do /bin/mv -f "tmp-$$f" "$$f" || /bin/true; done

%-${DB}.bo: %.fa ${DB}.phr
	${CMDLINE} -i $< -d ./${DB} >$@.tmp
	/bin/mv -f $@.tmp $@

.PRECIOUS: %-${DB}.load
%-${DB}.load: %-${DB}.bo
	load-papseq <$< >$@.tmp 2>&1
	/bin/mv -f $@.tmp $@

%.load: %-${DB}.load; 


.done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PARAMS_ID}' >$@.tmp
	/bin/mv -f $@.tmp $@

clean::
cleaner::
	/bin/rm -f *.bo *.log
cleanest::
	/bin/rm -f *.fa *.phr *.pin *.psq
