.PHONY: FORCE FORCED_BUILD
.SUFFIXES:


COMPBIO:=/gne/compbio
UHOME:=${HOME}/csb-db/unison

PATH:=${UHOME}/sbin:${UHOME}/bin:${UHOME}/misc
PATH:=${PATH}:${COMPBIO_EPREFIX}/bin:${COMPBIO_PREFIX}/bin
PATH:=${PATH}:/usr/local/pbs/bin:/usr/local/tools/bin:/usr/bin:/bin
export PATH

export PGUSER:=loader
export PGHOST:=csb
export PGDATABASE:=csb-dev
export PERL5LIB:=${UHOME}/perl5:${PERL5LIB}

RENAME=${HOME}/opt/bin/rerename


### QSUB arguments and command
# -V is necessary since we'll pass passwords in the env.
Q:=
QPPN:=2
QNODES:=nodes=1:ppn=${QPPN}
QTIME:=120000:00
QOE:=-ogoose.gene.com:${PWD}/$@.out -egoose.gene.com:${PWD}/$@.err
QSUB:=qsub -V -lwalltime=${QTIME},pcput=${QTIME},${QNODES} ${QOE}


vpath %.ids ids



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

# wanted.ids and done.ids files (or rules) must exist
todo.ids: wanted.ids done.ids
	comm -23 $^ >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@

genengenes.ids sugen.ids pdb.ids: %.ids:
	psql -Atc "select pseq_id from palias where porigin_id=porigin_id('$*')" >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv $@.tmp $@
	@wc -l $@
pset%.ids:
	psql -Atc 'select pseq_id from pseqset where pset_id=$*' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv $@.tmp $@
	@wc -l $@
fam%.ids:
	psql -Atc 'select distinct pseq_id from sst.v_fam_pseq where famid=$*' >$@.tmp
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


# get sequences for a set of ids
%.fa: %.ids
	get-seq <$< >$@.tmp \
	&& /bin/mv $@.tmp $@

# get a sequence
%.fa:
	get-seq $* >$@.tmp \
	&& /bin/mv $@.tmp $@


# Any target can be a qsub target
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
	@N=`expr '$*' : '\(.*\)\.[a-z]*'`; \
	set -x; \
	echo "make -C${PWD} $*" \
	| ${QSUB} -N$$N >$@.tmp
	/bin/mv -f $@.tmp $@

#qdel:
#	qstat -urkh | grep '^[0-9]' | cut -f1 -d. | xargs -t qdel




# -Nn rules: split .ids files into n sets, approximately the same number
# of ids in each set
%-N10: %.ids
	mkdir  "$*"
	N=`wc -l <$< `; L=`expr $$N / 10 + 1`; split -l$$L "$<" "$*/"
	${RENAME} 's/$$/.ids/' "$*"/??
%-N20: %.ids
	mkdir  "$*"
	N=`wc -l <$< `; L=`expr $$N / 20 + 1`; split -l$$L "$<" "$*/"
	${RENAME} 's/$$/.ids/' "$*"/??
%-N30: %.ids
	mkdir  "$*"
	N=`wc -l <$< `; L=`expr $$N / 30 + 1`; split -l$$L "$<" "$*/"
	${RENAME} 's/$$/.ids/' "$*"/??


# -ln rules: split .ids file into files of n lines each
%-l50: %.ids
	mkdir  "$*"
	split -l50 "$<" "$*/"
	${RENAME} 's/$$/.ids/' "$*"/??
%-l100: %.ids
	mkdir  "$*"
	split -l100 "$<" "$*/"
	${RENAME} 's/$$/.ids/' "$*"/??
%-l250: %.ids
	mkdir "$*"
	split -l250 "$<" "$*/"
	${RENAME} 's/$$/.ids/' "$*"/??
%-l500: %.ids
	mkdir "$*"
	split -l500 "$<" "$*/"
	${RENAME} 's/$$/.ids/' "$*"/??
%-l1000: %.ids
	mkdir "$*"
	split -l1000 "$<" "$*/"
	${RENAME} 's/$$/.ids/' "$*"/??


# %-load -- make the .load targets for a set of .id files, run locally
# %-qload -- same, but submit each job to qsub
# e.g., make pset42-todo-qload
PREFIX=?
%-load: %
	@for f in $*/${PREFIX}?.ids; do echo "$${f%ids}load"; done | tr \\012 \\0 | xargs -0rt ${MAKE}
%-qload: %
	@for f in $*/${PREFIX}?.ids; do echo "qsub/$${f%ids}load"; done | tr \\012 \\0 | xargs -0rt ${MAKE}





# gzip
%.gz:: %
	gzip $<
%:: %.gz
	gzip -d $<


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
	find . -name pset\* -type d -print0 | xargs -0rt /bin/rm -fr
cleanest:: cleaner
	/bin/rm -fr *.ids *.load *.log
