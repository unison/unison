.SUFFIXES:
.PHONY: FORCE FORCED_BUILD


COMPBIO:=/gne/compbio
UHOME:=${HOME}/csb-db/unison
SHELL:=/bin/bash

PATH:=${UHOME}/sbin:${UHOME}/bin:${UHOME}/misc
PATH:=${PATH}:${COMPBIO_EPREFIX}/bin:${COMPBIO_PREFIX}/bin
PATH:=${PATH}:/usr/pbs/bin:/usr/local/tools/bin:/usr/bin:/bin
export PATH

export PGUSER:=loader
export PGHOST:=csb
export PGDATABASE:=csb-dev
export PERL5LIB:=${UHOME}/perl5:${PERL5LIB}

RENAME=${HOME}/opt/bin/rerename

PSQL:=psql -Uunison
PSQL_CMD:=${PSQL} -At -c

SUBDIR:=$(shell basename ${PWD})

PSET_ID_A:=60
PSET_ID_B:=61
PSET_ID_C:=62

# %.ids files, relative to subdirs
vpath %.ids ../ids


ids: FORCE
	mkdir -p $@
	make -C ids -f ../defaults.mk runA.ids runB.ids runC.ids


### QSUB arguments and command
# -V is necessary since we'll pass passwords in the env.
# eg$ make PBSARCH=xeon
QPPN:=2
QNODES:=nodes=1:ppn=${QPPN}
ifdef PBSARCH
QNODES:=${QNODES}:${PBSARCH}
endif
QTIME:=120000:00
#QOE:=-ogoose.gene.com:${PWD}/$@.out -egoose.gene.com:${PWD}/$@.err
QSUB:=qsub -V -lwalltime=${QTIME},pcput=${QTIME},${QNODES} ${QOE}



ifdef DEBUG
$(warning UHOME=${UHOME} )
$(warning PGUSER=${PGUSER} )
$(warning PGDATABASE=${PGDATABASE} )
$(warning PERL5LIB=${PERL5LIB} )
$(warning QSUB=${QSUB} )
endif

ifndef PGPASSWORD
$(warning PGPASSWORD isn't set ) 	#'
endif

FORCE=
ifdef FORCE
# if FORCE is defined (e.g., make target FORCE=1), then reset FORCE to be the 
# phony target FORCED_BUILD, which does what you'd guess (unless you're dense)
override FORCE=FORCED_BUILD
endif


# Guarantee that including this file (defaults.mk) doesn't
# create a default target. Ideally, the includer will
# place a default target above the include defaults.mk line.
NO_DEFAULT_TARGET:
	@echo "no default target" 1>&2; exit 1


# set handling
%-todo.ids: %.ids done.ids
	comm -23 $^ >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@

# sequences by from unison's psets
runA.ids runB.ids runC.ids uniA.ids uniB.ids uniC.ids uniD.ids: %.ids:
	psql -Atc "select pseq_id from pseqset where pset_id=pset_id('$*')" >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv $@.tmp $@
	@wc -l $@
pset%.ids:
	psql -Atc 'select pseq_id from pseqset where pset_id=$*' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv $@.tmp $@
	@wc -l $@

# sequence lists by origin
genengenes.ids sugen.ids pdb.ids: %.ids:
	psql -Atc "select pseq_id from palias where porigin_id=porigin_id('$*')" >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv $@.tmp $@
	@wc -l $@
ggi.ids:
	psql -Atc "select distinct pseq_id from palias where porigin_id=porigin_id('GGI')" >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv $@.tmp $@
	@wc -l $@
ggi1.ids:
	psql -Atc "select distinct pseq_id from palias where porigin_id=porigin_id('GGI') and descr ~ ' 1/'" >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv $@.tmp $@
	@wc -l $@
ggi-se1.ids:
	psql -Atc "select distinct pseq_id from palias where porigin_id=porigin_id('GGI') and descr ~ ' 1-1 ' and descr ~ ' 1/'" >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv $@.tmp $@
	@wc -l $@
ggi-me1.ids:
	psql -Atc "select distinct pseq_id from palias where porigin_id=porigin_id('GGI') and descr !~ ' 1-1 ' and descr ~ ' 1/'" >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv $@.tmp $@
	@wc -l $@

# sequence lists by other info
fam%.ids:
	psql -Atc 'select distinct pseq_id from sst.v_fam_pseq where famid=$*' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv $@.tmp $@
	@wc -l $@


# -Nn rules: split .ids files into N sets, approximately the same number
# of ids in each set
%-N2 %-N3 %-N5 %-N10 %-N25 %-N50 %-N100 %-N250 %-N500: %.ids
	@mkdir "$@"
	@N=`expr "$@" : '.*-N\([0-9][0-9]*\)$$'`; \
	wcl=`wc -l <$< `; L=`expr $$wcl / $$N + 1`; \
	echo "L = wcl / N = $$wcl / $$N = $$L"; \
	set -x; split -l$$L "$<" "$@/"
	${RENAME} 's/$$/.ids/' "$@"/??

# -ln rules: split .ids file into files of l lines each
%-l5 %-l10 %-l50 %-l100 %-l250 %-l500 %-l1000 %-l5000 %-l10000: %.ids
	mkdir "$@"
	@l=`expr "$@" : '.*-l\([0-9][0-9]*\)$$'`; \
	set -x; split -l$$l "$<" "$@/"
	${RENAME} 's/$$/.ids/' "$@"/??


# Any target can be farmed to PBS by preceeding it with 'qsub/'
# e.g., $ make qsub/FOO.log
# make -n ensures that the target is legit and that make
# can figure out how to build it
qsub/%:
	@mkdir -p ${@D}
	@if ! make -C${PWD} -n $* >/dev/null 2>/dev/null; then \
		echo "couldn't make -n $* -- impossible target" 1>&2; \
		exit 1; \
	fi
	@mkdir -p "${@D}"
#	@N=`expr '$*' : '\(.*\)\.[a-z]*'`; 
	@N="${SUBDIR}/`basename '$(basename $*)'`"; \
	set -x; \
	echo "make -C${PWD} $*" | ${QSUB} -N$$N >$@.tmp
	/bin/mv -f $@.tmp $@

#qdel:
#	qstat -urkh | grep '^[0-9]' | cut -f1 -d. | xargs -t qdel


# %-load -- make the .load targets for a set of .id files, run locally
# %-qload -- same, but submit each job to qsub
# e.g., make pset42-todo-l500-qload
PREFIX=?
%-load: %
	@for f in $*/${PREFIX}?.ids; do echo "$${f%ids}load"; done | tr \\012 \\0 | xargs -0rt ${MAKE} $J
%-qload: %
	@for f in $*/${PREFIX}?.ids; do echo "qsub/$${f%ids}load"; done | tr \\012 \\0 | xargs -0rt ${MAKE} $J


# gzip
%.gz:: %
	gzip $<
%:: %.gz
	gzip -d $<

# get sequences for a set of ids
%.fa: %.ids
	get-seq <$< >$@.tmp \
	&& /bin/mv $@.tmp $@

# get a sequence
%.fa:
	get-seq $* >$@.tmp \
	&& /bin/mv $@.tmp $@




env:
	env | sort >$@ 2>&1


# Generic cleaning rules
.PHONY: clean cleaner cleanest
clean::
	/bin/rm -f *~ *.bak
	/bin/rm -f *.tmp
	/bin/rm -fr *.err
cleaner:: clean
	/bin/rm -fr qsub todo
	/bin/rm -f *.load *.log
	/bin/rm -f *.[eo][0-9][0-9]*[0-9]
cleanest:: cleaner
	/bin/rm -fr *.ids *.load *.log
	/bin/rm -fr *-N[1-9] *-N[1-9][0-9] *-N[1-9][0-9][0-9]
	/bin/rm -fr          *-l[1-9][0-9] *-l[1-9][0-9][0-9] *-l[1-9][0-9][0-9][0-9]
	find . -name pset\* -type d -print0 | xargs -0rt /bin/rm -fr
