include ../defaults.mk

#PMSET:=-M3
#HMMARGS:=-N1000
PARAMS_ID:=21
PORIGIN_ID:=10060


default:
	@echo no $@ target; exit 1


#%.load: %.ids
#	(time -p run-pahmm ${HMMARGS} <$<) >$@.err 2>&1;
#	/bin/mv -f $@.err $@.log; touch $@

%.load: %.hmmer
	(time -p load-pahmm -p${PARAMS_ID} -o${PORIGIN_ID} $<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

%.hmmer: %.fa
	/gne/compbio/i686-linux-2.6/bin/ldhmmpfam -Z7868 -E10 /gne/compbio/share/pfam/Pfam_fs.hmmb $< >$@.tmp 2>$@.err
	/bin/mv -f $@.tmp $@
	/bin/mv -f $@.err $@.log

done.ids:
	psql -Atc 'select pseq_id from run_history where params_id=${PARAMS_ID}' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@
