include ../common.mk

PATH:=${COMPBIO_EPREFIX}/bin:${PATH}

PARAMS_ID:=20
SEQS_PER_RUN:=10


default:
	@echo no $@ target; exit 1

ifeq '$(shell uname -s)' 'OSF1'
# uname -s == OSF1 is a surrogate for whether we're on geneland
%.load: %.ids
	(time -p run-psprotcomp -N${SEQS_PER_RUN} <$<) >$@.err 2>&1
	/bin/mv -f $@.err $@
else
%.load: %.ids
	@echo ERROR: protcomp must be run on geneland; exit 1
endif


done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=20' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@
