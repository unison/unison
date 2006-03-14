default all: update

include ../common.mk
include ../local.mk
include ../params.mk

DB:=uniblast
PARAMS_ID:=3
RUNSET:=runA
N:=10

update:
	make cleaner
	make done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N${N}
	make ${RUNSET}-todo-N${N}-qload


# alias .load := -unisondb.load
.PHONY: %.load
%.load: %-${DB}.load;

.PRECIOUS: %-${DB}.load
%-${DB}.load: %-${DB}.bo
	(time -p load-papseq <$<) >$@.err 2>&1
	/bin/mv -f $@.err $@

.PRECIOUS: %-${DB}.bo
%-${DB}.bo: %.fa ${DB}.phr
	(time -p ${PAPSEQ_CMDLINE} -i $< -d ./${DB}) >$@.tmp 2>&1
	/bin/mv -f $@.tmp $@

.PRECIOUS: %.log %.fa
%.phr: %.fa
	formatdb -t "$* `date +'%Y-%m-%d %H:%M'`" -l $@.log -pT -n tmp-$* -i $<
	for f in $*.phr $*.pin $*.psq; do /bin/mv -f "tmp-$$f" "$$f" || /bin/true; done

.PRECIOUS: uniblast.fa
uniblast.fa:
	get-seq -v -SS uniblast >$@.tmp
	/bin/mv -f $@.tmp $@

.done.ids:
	${PSQL_DCMD} 'select pseq_id from run_history where params_id=${PARAMS_ID}' >$@.tmp
	/bin/mv -f $@.tmp $@


.PHONY: db
db: .${DB}-built

# the following include forces the db to be built before
# any qsubs occur
#include .${DB}-built
#.%-built: %.phr
#	touch $@



clean::
cleaner::
	/bin/rm -f *.bo *.log
cleanest::
	/bin/rm -f .*-built *.fa *.phr *.pin *.psq
