.PHONY: FORCE
.SUFFIXES:

NPRE:=
NSPLIT:=4000
QSUB:=qsub -qall -lwalltime=12000:00,pcput=6000:00,nodes=1:ppn=2 -V
export PROSPECT_PATH:=/apps/compbio/i686-linux-2.4/opt/prospect
PATH:=/home/rkh/unison/bin:${PROSPECT_PATH}:${PATH}
export PGPASSWORD:=marge

export LD_LIBRARY_PATH=/home/rkh/opt/i686-linux-2.4/lib
export PERL5LIB=/home/rkh/opt/lib/perl5/site_perl:/home/rkh/opt/lib/perl5

PROSPECT:=prospect -ncpus 2

mtr=mtA
-include .${mtr}.var


default all: ${TARGETS}

#1/1234/seq.log:
#@s=$(dirpart $(subst /seq.log,,${@D})
@pseqid=$(shell expr "${@D}" : 'no/[0-9][0-9]*/\([0-9][0-9]*\)')
%/seq.fa:
	@mkdir -p ${@D}
	get-seq ${@pseqid} >$@.tmp
	mv -f $@.tmp $@


%/scop.xml: %/seq.fa
	(time -p ${PROSPECT} -seqfile $< -o $@.tmp -scop -global) >$@.log 2>&1
	mv -f $@.tmp $@
%/scop-gl.xml: %/seq.fa
	@mkdir -p $*
	(time -p ${PROSPECT} -seqfile $< -o $@.tmp -scop -global_local) >$@.log 2>&1
	mv -f $@.tmp $@
%/fssp.xml: %/seq.fa
	@mkdir -p $*
	(time -p ${PROSPECT} -seqfile $< -o $@.tmp -fssp -global) >$@.log 2>&1
	mv -f $@.tmp $@
%/fssp-gl.xml: %/seq.fa
	@mkdir -p $*
	(time -p ${PROSPECT} -seqfile $< -o $@.tmp -fssp -global_local) >$@.log 2>&1
	mv -f $@.tmp $@

%/tnf.xml: %/seq.fa
	@mkdir -p $*
	(time -p ${PROSPECT} -tfile ${HOME}/prospect/tfiles/tnfsf -seqfile $< -o $@.tmp ) >$@.log 2>&1
	mv -f $@.tmp $@

%/all.xml: %/seq.fa
	@mkdir -p $*
	(time -p ${PROSPECT} -tfile ${HOME}/prospect/tfiles/all -seqfile $< -o $@.tmp ) >$@.log 2>&1
	mv -f $@.tmp $@

%.sort: %.xml
	sync
	sortProspect $< >$@.tmp
	mv -f $@.tmp $@

%-load.log: %.xml %.sort
	(time -p load-p2thread -Uloader -x $*.xml -s $*.sort) >$@.tmp 2>&1
	/bin/mv -f $@.tmp $@


mt.ids:
	psql -tA -dunison -htd-sprog  \
	-c "select distinct pseq_id from palias where (porigin_id in (14,15,10009,100010,10011,10012,10013) or alias ilike '%hum%') order by pseq_id" | sort >$@

tnfsf.p2tids: tnfsf
	perl -e 'BEGIN{$$q=chr(39)}' \
	-e 'print "select p2template_id from p2template where name in (",join(",",map {chomp;"$$q$$_$$q"} <>),")"' $< \
	| psql -tA -dunison -htd-sprog -f- >$@
mt2.i1: tnfsf.p2tids
	perl -e 'print "select pseq_id,count(*) from p2thread where p2template_id in (",join(",",map {chomp;$$_} <>),") group by pseq_id"' $< \
	| psql -tA -dunison -htd-sprog -f- >$@
mt2.i2: mt2.i1
	perl -lne '@F=split(/\|/); print $$F[0] if ($$F[1]==21)' $< | sort >$@.tmp
	/bin/mv -f $@.tmp $@
mt2.ids: mt.ids mt2.i2
	comm $^ -23 >$@


counts: FORCE
	psql -htd-sprog -dunison \
	-c 'select pseq_id,count(*) from p2thread group by pseq_id order by pseq_id' >$@
misloads: counts
	grep -v 3269 $< >$@


${mtr}: ${mtr}.ids
	perl -pe 's/\.fa//; s/^(\d*?)\d{1,2}$$/sprintf("no\/%d\/$$&",$$1||0)/e;' <$< \
	| perl -lne 'chomp; $$r=$$_; print( map { "$$r/$$_ " } qw( all.xml ) )' >$@
	@wc -l $@
${mtr}d: ${mtr}
	rm -fr $@; mkdir -p $@
	split -l${NSPLIT} $< $@/
	@echo `find ${mtr}d -type f | wc -l` ${mtr}d targets
${mtr}d/%.log: ${mtr}d/%
	(echo 'xargs <${PWD}/$< make -C${PWD} -k >>${PWD}/$@ 2>&1') \
	| ${QSUB} -N${NPRE}$< -o$<.out -e$<.err
qsub: $(addsuffix .log, $(wildcard ${mtr}d/??))
qdel:
	qstat -urkh | grep '^[0-9]' | cut -f1 -d. | xargs -t qdel


.%.var: %
	(/bin/echo -n TARGETS=; cat $<) | tr \\n ' ' >$@
#	(/bin/echo -n $*=; cat $<) | tr \\n ' ' >$@


.PHONY: clean cleaner cleanest
clean:
	/bin/rm -fr *~ *.tmp*
cleaner: clean
	/bin/rm -fr *.bak
cleanest: cleaner
	/bin/rm -fr ${mtr} ${mtr}d seqs.ls
	/bin/rm -fr *_HUMAN *_HUMAN-nosig


# tallac$ perl -e '$n=123456;  $r = join("/", (map {substr($n,0,2*$_)} 1..(length($n)-1)/2), $n); print "$n -> $r\n"'
# 12345 -> 12/1234/12345
# 123456 -> 12/1234/123456
