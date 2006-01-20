## unison/loading/common.mk -- common rules used by the Unison loading mechanism
## $Id: common.mk,v 1.22 2006/01/02 05:41:02 rkh Exp $

.SUFFIXES:
.PHONY: FORCE
.DELETE_ON_ERROR:


# Calling Makefiles are expected to define a 'default' rule This rule
# guarantees that the rule called 'default' is invoked even when common.mk
# is included before defining other rules.
commonmk_default: default

SHELL:=/bin/bash

PSQL:=psql -X
PSQL_VCMD:=${PSQL} -c
PSQL_DCMD:=${PSQL} -UPUBLIC -At -c



############################################################################
#########################  SEQUENCE SET HANDLING  ##########################
# id sets are built in two phases:
# 1) select sequences into filenames like '.set.ids';
# 2) sort them in this rule into a file like 'set.ids'
# (sorted locally to ensure consistent LANG sorting rules)
############################################################################
%.ids: .%.ids
	sort -u -o $@ $<; wc -l $@

# sequences by from unison's psets
vpath %.ids .:..
.PHONY: ids
ids: runA.ids runB.ids runC.ids
.runA.ids .runB.ids .runC.ids .uniA.ids .uniB.ids .uniC.ids .uniD.ids: .%.ids:
	${PSQL_DCMD} "select pseq_id from pseqset where pset_id=pset_id('$*')" >$@
.runA-human.ids .runB-human.ids .runC-human.ids .uniA-human.ids .uniB-human.ids .uniC-human.ids .uniD-human.ids: .%-human.ids:
	${PSQL_DCMD} "select pseq_id from pseqset where pset_id=pset_id('$*') intersect select pseq_id from pseqset where pset_id=pset_id('Human')" >$@
.pset%.ids:
	${PSQL_DCMD} 'select pseq_id from pseqset where pset_id=$*' >$@
.porigin%.ids:
	${PSQL_DCMD} 'select distinct pseq_id from palias where porigin_id=$*' >$@

# generic set-todo.ids is anything which hasn't been done already
# The top-level makefile which included this one must
# provide a 'done.ids' target.
.%-todo.ids: %.ids done.ids
	comm -23 $^ >$@

# 'O-': sequence ids by origin
.O-%.ids:
	${PSQL_DCMD} "select distinct pseq_id from palias where porigin_id=porigin_id('$*')" >$@

# genentech sequence lists by origin
# FIXME: genentech stuff still in this common file... it'd be nice to move this
# elsewhere.
.genengenes.ids .sugen.ids .pdb.ids: .%.ids:
	${PSQL_DCMD} "select pseq_id from palias where porigin_id=porigin_id('$*')" >$@
.ggi.ids:
	${PSQL_DCMD} "select distinct pseq_id from palias where porigin_id=porigin_id('GGI')" >$@
.ggi1.ids:
	${PSQL_DCMD} "select distinct pseq_id from palias where porigin_id=porigin_id('GGI') and descr ~ ' 1/'" >$@
.ggi-se1.ids:
	${PSQL_DCMD} "select distinct pseq_id from palias where porigin_id=porigin_id('GGI') and descr ~ ' 1-1 ' and descr ~ ' 1/'" >$@
.ggi-me1.ids:
	${PSQL_DCMD} "select distinct pseq_id from palias where porigin_id=porigin_id('GGI') and descr !~ ' 1-1 ' and descr ~ ' 1/'" >$@
.rungga.ids:
	${PSQL_DCMD} "select pseq_id * from pset_rungga_dv" >$@

# sequence lists by other info
.fam%.ids:
	${PSQL_DCMD} 'select distinct pseq_id from unison.gg_famid_pseq_id_v where famid=$*' >$@


# -Nn rules: split .ids files into N sets, w/ approximately the same number
# of ids in each set (+/-1)
### FIXME: I don't like the dependency of this rule on RENAME outside of this
### scope.
%-N2 %-N3 %-N4 %-N5 %-N10 %-N15 %-N20 %-N25 %-N50 %-N100: %.ids
	@mkdir "$@"
	@N=`expr "$@" : '.*-N\([0-9][0-9]*\)$$'`; \
	wcl=`wc -l <$< `; L=`expr $$wcl / $$N + 1`; \
	echo "L = wcl / N = $$wcl / $$N = $$L"; \
	set -x; split -l$$L "$<" "$@/"
	touch "$@"/aa				# empty file prevents "impossible target" errors
	${RENAME} 's/$$/.ids/' "$@"/??

# -ln rules: split .ids file into files of l lines each
%-l5 %-l10 %-l50 %-l100 %-l250 %-l500 %-l1000 %-l5000 %-l10000: %.ids
	mkdir "$@"
	@l=`expr "$@" : '.*-l\([0-9][0-9]*\)$$'`; \
	set -x; split -l$$l "$<" "$@/"
	${RENAME} 's/$$/.ids/' "$@"/??



############################################################################
###########################	 PBS QUEUING SETUP  ############################
############################################################################

# -V is necessary since we'll pass passwords in the env.
# eg$ make PBSARCH=xeon
QPPN:=2
QNODES:=nodes=1:ppn=${QPPN}
ifdef Q
QUEUE=-q${Q}
endif
ifdef PBSARCH
QNODES:=${QNODES}:${PBSARCH}
endif
QTIME:=120000:00
#QOE:=-ogoose.gene.com:${PWD}/$@.out -egoose.gene.com:${PWD}/$@.err
QSUB:=qsub ${QUEUE} -V -lwalltime=${QTIME},pcput=${QTIME},${QNODES} ${QOE}



# Any target can be farmed to PBS by preceeding it with 'qsub/'
# e.g., $ make qsub/FOO.log
# make -n ensures that the target is legit and that make
# can figure out how to build it
SUBDIR:=$(shell basename ${PWD} | tr -d _)
QNAME:=${SUBDIR}
qsub/%:
	@mkdir -p ${@D}
	@if ! make -C${PWD} -n $* >/dev/null 2>/dev/null; then \
		echo "couldn't make -n $* -- impossible target" 1>&2; \
		exit 1; \
	fi
	@mkdir -p "${@D}"
	@N="${QNAME}/`basename '$(basename $*)'`"; \
	if [ "$${#N}" -gt "15" ]; then N=$${N:$${#N}-15:15}; fi; \
	echo "make -C${PWD} $*" | ${QSUB} -N"$$N" >$@.tmp
	@/bin/mv -f $@.tmp $@
	@echo "make -C${PWD} $*": `cat $@`

#qdel:
#	qstat -urkh | grep '^[0-9]' | cut -f1 -d. | xargs -t qdel


# %-load -- make the .load targets for a set of .id files, run locally
# %-qload -- same, but submit each job to qsub
# e.g., make pset42-todo-l500-qload
PATTERN=*
%-load: %
	@for f in $*/${PATTERN}.ids; do echo "$${f%ids}load"; done | tr \\012 \\0 | xargs -0rt ${MAKE} $J
%-qload: %
	@for f in $*/${PATTERN}.ids; do echo "qsub/$${f%ids}load"; done | tr \\012 \\0 | xargs -0rt ${MAKE} $J



############################################################################
##########################	MISCELLANEOUS RULES  ###########################
############################################################################

# gzip
%.gz:: %
	gzip $<
%:: %.gz
	gzip -d $<

# get sequences for a set of ids
%.fa: %.ids
	get-seq -v <$< >$@

# get a sequence
%.fa:
	get-seq $* >$@

# make env -- write env to file `env' for debugging
env:
	env | sort >$@ 2>&1


# Generic cleaning rules
.PHONY: clean cleaner cleanest
clean::
	/bin/rm -f *~ *.bak
	/bin/rm -f *.tmp
	/bin/rm -fr *.err
cleaner:: clean
	/bin/rm -f .*.ids *.ids
	/bin/rm -f *.load *.log
	/bin/rm -f *.[eo][0-9][0-9]*[0-9]
	/bin/rm -fr qsub todo
cleanest:: cleaner
	/bin/rm -f *.load *.log
	/bin/rm -fr *-N[1-9] *-N[1-9][0-9] *-N[1-9][0-9][0-9]
	/bin/rm -fr          *-l[1-9][0-9] *-l[1-9][0-9][0-9] *-l[1-9][0-9][0-9][0-9]
