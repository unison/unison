default: update

include ../common.mk
include ../local.mk
include ../params.mk

RUN_ID:=`${PSQL_DCMD} "select preferred_run_id_by_pftype('disorder')"`

N:=5
QNAME=${SUBDIR}p${RUN_ID}
RUNSET=runB-human
NPER:=250

default:
	@echo no default target; exit 99

update:
	make cleanest
	make done.ids ${RUNSET}-todo.ids ${RUNSET}-todo-N${N}
	make ${RUNSET}-todo-N${N}-qload

.PRECIOUS: todo.disprot
%.disprot: %.fa
	-./bin/disprot.pl --nowarn <$< >$@ 2>$@.err
	/bin/mv -f $@.err $@.log
	tail $@.log

%.load: %.disprot
	./bin/disprot-to-sql.pl $< | psql >$@.tmp 2>&1
	/bin/mv -f $@.tmp $@

.done.ids:
	${PSQL_DCMD} "select pseq_id from run_history where run_id=${RUN_ID}" >$@





.helicase.ids:
	${PSQL_DCMD} 'select pseq_id from rkh.helicase_to_run' >$@

helicase-todo.fa: helicase-todo.ids
	unison-get-seq --iupac20 -v <$< >$@.tmp
	/bin/mv $@.tmp $@
