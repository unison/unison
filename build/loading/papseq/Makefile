include ../defaults.mk

BLAST:=blastall -p blastp -F F -e 1e-20 -z2829482

default:
	@echo no $@ target; exit 1

%.phr: %.fa
	formatdb -t "PDB `date +'%Y-%m-%d %H:%M'`" -l $@.log -pT -n tmp-$* -i $<
	for f in $*.phr $*.pin $*.psq; do /bin/mv -f "tmp-$$f" "$$f" || /bin/true; done

%-unison.bo: %.fa unison.phr
	${BLAST} -i $< -d ./unison >$@.tmp
	/bin/mv -f $@.tmp $@

%-pdb.bo: %.fa pdb.phr
	${BLAST} -i $< -d ./pdb >$@.tmp
	/bin/mv -f $@.tmp $@

%.load: %.bo
	load-papseq <$< >$@.tmp 2>&1
	/bin/mv -f $@.tmp $@


clean::
	/bin/rm -f *.bo
cleaner::
	/bin/rm -f *.phr *.pin *.psq
	/bin/rm -f *.bo *.log
cleanest::
	/bin/rm -f *.fa
