include ../defaults.mk

#PMSET:=-M3
#HMMARGS:=--pfam=12fs
PARAMS_ID:=18


default:
	@echo no $@ target; exit 1


%.load: %.ids
	(time -p run-pahmm ${HMMARGS} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=18' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@
