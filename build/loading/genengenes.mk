default all:
	@echo "this make file is for genengenes auto loaded seqeunces, try ggauto-todo.ids, ggauto-todo-N5 ggauto-todo-N5-load"
include local.mk
include common.mk

COMPUTE_DIRS:=pahmm
COMPUTE_DIRS+=pfbigpi pfsignalp pftmhmm pfregexp
COMPUTE_DIRS+=psprotcomp

CTARGETS:= clean cleaner cleanest
 TARGETS:= done.ids
LTARGETS:= %.load %-load %-qload 
BTARGETS:= %-N2 %-N3 %-N4 %-N5 %-N10 %-N15 %-N20 %-N25 %-N50 %-N100 %-l5 %-l10 %-l50 %-l100 %-l250 %-l500 %-l1000 %-l5000 %-l10000

ggauto.ids:
	${PSQL_DCMD} "select pseq_id from palias where porigin_id=porigin_id('genengenes auto') EXCEPT select pseq_id from pseqset where pset_id=pset_id('no run')" | sort -u >$@

${CTARGETS}::
	$(foreach DIR,${COMPUTE_DIRS}, make -C ${DIR} $@;)

${TARGETS} ${LTARGETS} ${BTARGETS}:
	$(foreach DIR,${COMPUTE_DIRS}, make -C ${DIR} $@;)

%-todo.ids: %.ids done.ids
	$(foreach DIR,${COMPUTE_DIRS}, make -C ${DIR} $@;)
