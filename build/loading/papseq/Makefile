default all: update

include ../common.mk
include ../local.mk
include ../params.mk

DB:=uniblast
RUNSET:=runC-human
N:=10
QPPN:=2

update:
	make cleaner
	make ${RUNSET}.ids done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N${N}
	make ${RUNSET}-todo-N${N}-qload

PAPSEQ_RUN_ID:=`${PSQL_DCMD} "select preferred_run_id_by_pftype('BLAST')"`

PAPSEQ_CMDLINE:=$(shell ${PSQL_DCMD} "select p.commandline||' -a "${QPPN}"' from params p join run r on r.params_id=p.params_id where r.run_id=${PAPSEQ_RUN_ID}")

PAPSEQ_DATA_DIR:=${UNISON_HOME}/runtime/data/papseq

# alias .load := -unisondb.load
.PHONY: %.load
%.load: %-${DB}.load;

.PRECIOUS: %-${DB}.load
%-${DB}.load: %-${DB}.bo
	(time -p load-papseq -r ${PAPSEQ_RUN_ID} --verbose <$<) >$@.err 2>&1
	/bin/mv -f $@.err $@.log; touch $@

.PRECIOUS: %-${DB}.bo
%-${DB}.bo: %.fa ${PAPSEQ_DATA_DIR}/${DB}.pal
	(time -p ${PAPSEQ_CMDLINE} -i $< -d ${PAPSEQ_DATA_DIR}/${DB}) >$@.tmp 2>&1
	/bin/mv -f $@.tmp $@

.PRECIOUS: %.log %.fa
%.phr: %.fa
	formatdb -t "$* `date +'%Y-%m-%d %H:%M'`" -l $@.log -pT -n tmp-$* -i $<
	for f in $*.00.phr $*.00.pin $*.00.psq $*.01.phr $*.01.pin $*.01.psq $*.pal; do /bin/mv -f "tmp-$$f" "$$f" || /bin/true; done

.PRECIOUS: uniblast.fa
uniblast.fa:
	unison-get-seq -v -SS uniblast >$@.tmp
	/bin/mv -f $@.tmp ${PAPSEQ_DATA_DIR}/$@

.done.ids:
	${PSQL_DCMD} "select pseq_id from run_history where run_id=${PAPSEQ_RUN_ID}" >$@.tmp
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
	/bin/rm -f *.bo *.log *.ids .*.ids
	/bin/rm -fr *-N[1-9] *-N[1-9][0-9] *-N[1-9][0-9][0-9]
cleanest::
	/bin/rm -f .*-built *.fa *.phr *.pin *.psq
