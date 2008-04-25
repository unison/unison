default all: update

include ../common.mk
include ../local.mk
include ../params.mk

DB:=uniblast
RUNSET:=runB
N:=10
QPPN:=8

update:
	make cleaner
	make ${RUNSET} done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N${N}
	make upd_pmpseq.ids
	make ${DB}.pal
	make ${RUNSET}-todo-N${N}-qload

PAPSEQ_RUN_ID:=`${PSQL_DCMD} "select preferred_run_id_by_pftype('BLAST')"`

PMPSEQ_UPD_CMD:= ${PSQL_DCMD} "insert into pmpseq(pseq_id) select s.pseq_id from pseqset s left join pmpseq m on m.pseq_id=s.pseq_id where s.pset_id=pset_id('uniblast') and m.pseq_id is null"

PAPSEQ_CMDLINE:=$(shell ${PSQL_DCMD} "select p.commandline||' -a "${QPPN}"' from params p join run r on r.params_id=p.params_id where r.run_id=${PAPSEQ_RUN_ID}")

PAPSEQ_DATA_DIR:=${UNISON_HOME}/runtime/data/papseq

upd_pmpseq.ids:
	time -p ${PMPSEQ_UPD_CMD} > $@.tmp 2>&1
	/bin/mv -f $@.tmp $@

${RUNSET}:
	${PSQL_DCMD} "select pseq_id from pseqset where pset_id=pset_id('$@') intersect select pseq_id from pseqset where pset_id=pset_id('uniblast')" >.$@.ids
	sort -u -o $@.ids .$@.ids; 
	wc -l $@.ids

# alias .load := -unisondb.load
.PHONY: %.load
%.load: %-${DB}.load;

.PRECIOUS: %-${DB}.load
%-${DB}.load: %.fa ${PAPSEQ_DATA_DIR}/${DB}.pal
	(time -p ${PAPSEQ_CMDLINE} -r ${PAPSEQ_RUN_ID} --verbose -i $< --database ${PAPSEQ_DATA_DIR}/${DB}) >$@.err 2>&1
	/bin/mv -f $@.err $@

.PRECIOUS: %.log %.fa
%.pal: %.fa
	formatdb -t "$* `date +'%Y-%m-%d %H:%M'`" -l $@.log -pT -n $* -i ${PAPSEQ_DATA_DIR}/$<
	for f in $*.0?.p?? $*.pal; do /bin/mv -f "$$f" ${PAPSEQ_DATA_DIR}/"$$f" || /bin/true; done

.PRECIOUS: uniblast.fa
uniblast.fa:
	${PSQL_DCMD} "select pseq_id from pseqset where pset_id=pset_id('uniblast')" > uniblast.ids
	sort -u uniblast.ids ${RUNSET}-todo.ids  > $@.tmp.ids
	cat $@.tmp.ids | unison-get-seq -v > $@.tmp
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
