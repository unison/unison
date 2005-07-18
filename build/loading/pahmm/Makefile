include ../common.mk

PARAMS_ID:=21
PORIGIN_ID:=10059
#PARAMS_ID:=22
#PORIGIN_ID:=10060

CMDLINE=$(shell ${PSQL_DCMD} -t 'select commandline from params where params_id=${PARAMS_ID}')
HMMB=$(shell ${PSQL_DCMD} -t 'select data_url from porigin where porigin_id=${PORIGIN_ID}')

# Use LDHMMER by uncommenting the following line
# PATH:=${COMPBIO_EPREFIX}/opt/ldhmmer:${PATH}


default:
	@echo no $@ target; exit 1


%.load: %.ids
	(time -p run-pahmm -N250 -p${PARAMS_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

.done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PARAMS_ID}' >$@.tmp


## The following circumvent run-pahmm. These are deprecated because
## it's impossible to guarantee that the loading parameters are really 
## those used to generated the HMMER output.

#%.load: %.hmmer
#	(time -p load-pahmm -p${PARAMS_ID} -o${PORIGIN_ID} $<) >$@.err 2>&1;
#	/bin/mv -f $@.err $@.log; touch $@

#.PRECIOUS: %.hmmer
#%.hmmer: %.fa
#	(time -p ${CMDLINE} ${HMMB} $< >$@.tmp) 2>$@.err
#	/bin/mv -f $@.tmp $@
#	/bin/mv -f $@.err $@.log

#pset%.hmmer:
#	@for f in pset$*/${PREFIX}?.ids; do echo "$${f%.ids}.hmmer"; done | tr \\012 \\0 | xargs -0rt ${MAKE}

