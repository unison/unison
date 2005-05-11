include ../defaults.mk

PARAMS_ID:=3
BLAST_CMD=$(shell ${PSQL_CMD} 'select commandline from params where params_id=${PARAMS_ID}')
DB:=unison

default:
	@echo no $@ target; exit 1

.PHONY: setup
setup: ${DB}.phr

unison.ids:
	${PSQL_CMD} "select pseq_id from pseqset where pset_id=pset_id('BLAST DB')" >$@.tmp
	/bin/mv -f $@.tmp $@

.PRECIOUS: %.phr
%.phr: %.fa
	formatdb -t "$* `date +'%Y-%m-%d %H:%M'`" -l $@.log -pT -n tmp-$* -i $<
	for f in $*.phr $*.pin $*.psq; do /bin/mv -f "tmp-$$f" "$$f" || /bin/true; done

%-${DB}.bo: %.fa ${DB}.phr
	${BLAST_CMD} -i $< -d ./${DB} >$@.tmp
	/bin/mv -f $@.tmp $@

.PRECIOUS: %-${DB}.load
%-${DB}.load: %-${DB}.bo
	load-papseq <$< >$@.tmp 2>&1
	/bin/mv -f $@.tmp $@

%.load: %-${DB}.load; 



clean::
cleaner::
	/bin/rm -f *.bo *.log
cleanest::
	/bin/rm -f *.fa *.phr *.pin *.psq
