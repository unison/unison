## This makefile is a disaster... it needs to be rewritten

.PHONY: FORCE
.SUFFIXES:

TFILE=all
S:=/apps/compbio/share
NPRE:=
NSPLIT:=5000
NJOBS:=52
Q:=xeons
QSUB:=qsub -q${Q} -lwalltime=120000:00,pcput=120000:00,nodes=1:ppn=2 -V
export PROSPECT_PATH:=/apps/compbio/i686-linux-2.4/opt/prospect
PATH:=/home/rkh/csb-db/unison/sbin:${PROSPECT_PATH}:${PATH}
export PATH

export LD_LIBRARY_PATH=/home/rkh/opt/i686-linux-2.4/lib
export PERL5LIB=/home/rkh/opt/lib/perl5/site_perl:/home/rkh/opt/lib/perl5

export PGHOST=svc
export PGDATABASE=csb-dev
export PGPASSWORD=marge

mtr=p1
include .${mtr}.var

RUN_ID=1
#TFILE:=all
TFILE:=c1qtnf
DIR:=${TFILE}-${RUN_ID}
RUNP2:=run-paprospect2 -dcsb-dev -Uloader -p${RUN_ID} -m10




default all: ${TARGETS}

# comp-side:

_D:=$(shell mkdir -p logs-${mtr})
logs-${mtr}/%.log:
	time -p ${RUNP2} $* 2>&1 | tee $@.tmp; /bin/mv -f $@.tmp $@
#	(set -x; time -p ${RUNP2} $*) >$@.tmp 2>&1 && /bin/mv -f $@.tmp $@


# qsub-side:
${mtr}.mt: ${mtr}.ids
	perl -lne 'print "logs-${mtr}/$$_.log"' <$< >$@
	@wc -l $@
${mtr}.d: ${mtr}.mt
	rm -fr $@; mkdir -p $@
	@nl=`wc -l <$<`; nsplit=`echo $$nl / ${NJOBS} + 1 | bc`; \
	echo "splitting into bins of $$nsplit"; \
	split -l$$nsplit $< $@/
	@echo `find ${mtr}.d -type f | wc -l` ${mtr}.d targets
${mtr}.d/%.log: ${mtr}.d/%
	(echo 'xargs <${PWD}/$< make -C${PWD} -k >>${PWD}/$@ 2>&1') \
	| ${QSUB} -N${mtr}_$* -o$<.out -e$<.err


qsub: $(addsuffix .log, $(wildcard ${mtr}.d/??))
qdel:
	qstat -urkh | grep '^[0-9]' | cut -f1 -d. | xargs -t qdel


.%.var: %.mt
	(/bin/echo -n TARGETS=; cat $<) | tr \\n ' ' >$@
#	(/bin/echo -n $*=; cat $<) | tr \\n ' ' >$@


.PHONY: clean cleaner cleanest
clean:
	/bin/rm -fr *~ *.tmp*
cleaner: clean
	/bin/rm -fr *.bak
cleanest: cleaner
	/bin/rm -f  *.mt *.ids
	/bin/rm -fr *.d no


# tallac$ perl -e '$n=123456;  $r = join("/", (map {substr($n,0,2*$_)} 1..(length($n)-1)/2), $n); print "$n -> $r\n"'
# 12345 -> 12/1234/12345
# 123456 -> 12/1234/123456
