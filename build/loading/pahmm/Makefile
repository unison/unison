include ../defaults.mk

#PMSET:=-M3

default:
	@echo no $@ target; exit 1


%.load: %.ids
	(time -p run-pahmm ${PMSET} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

%.load: %.fa
	(time -p hmmpfam --informat fasta ${PFAMDB} $< \
	| load-pahmm) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@
