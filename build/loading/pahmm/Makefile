include ../defaults.mk

#PMSET:=-M3
#HMMARGS:=--pfam=12fs


default:
	@echo no $@ target; exit 1


%.load: %.ids
	(time -p run-pahmm ${HMMARGS} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

done.ids:
#12.0fs:psql -Atc 'select pseq_id from run_history where params_id=13 and porigin_id=10044' >$@.tmp
	psql -Atc 'select pseq_id from run_history where params_id=15 and porigin_id=10050' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@
