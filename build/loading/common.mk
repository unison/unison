.PHONY: FORCE
.SUFFIXES:


COMPBIO:=/apps/compbio
UHOME:=${HOME}/csb-db/unison

PATH:=${UHOME}/sbin:${UHOME}/bin:${UHOME}/misc
PATH:=${PATH}:${COMPBIO}/i686-linux-2.4/bin:${COMPBIO}/bin
PATH:=${PATH}:/usr/local/pbs/bin:/usr/local/tools/bin:/usr/bin:/bin
export PATH

export PGUSER:=loader
export PGDATABASE:=csb-dev
export PERL5LIB:=${UHOME}/perl5


### QSUB arguments and command
# -V is necessary since we'll pass passwords in the env.
Q:=all
QPPN:=2
QNODES:=nodes=1:ppn=${QPPN}
QTIME:=120000:00
QSUB:=PGHOST=svc qsub -V -q${Q} -lwalltime=${QTIME},pcput=${QTIME},${QNODES}


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


# Guarantee that including this file (defaults.mk) doesn't
# create a default target. Ideally, the includer will
# place a default target above the include defaults.mk line.
NO_DEFAULT_TARGET:
	@echo "no default target" 1>&2; exit 1


# groups of pseq_ids
pset%.ids:
	psql -Atc 'select pseq_id from pseqset where pset_id=$*' >$@.tmp
	/bin/mv $@.tmp $@
	@wc -l $@
fam%.ids:
	psql -Atc 'select distinct pseq_id from sst.v_fam_pseq where famid=$*' >$@.tmp
	/bin/mv $@.tmp $@
	@wc -l $@
ggi.ids:
	psql -Atc "select distinct pseq_id from palias where porigin_id=porigin_id('GGI')" >$@.tmp
	/bin/mv $@.tmp $@
	@wc -l $@


# get sequences for a set of ids
%.fa: %.ids
	get-seq <$< >$@.tmp \
	&& /bin/mv $@.tmp $@


# Any target can be a qsub target
# e.g., $ make qsub/FOO.log
# make -n ensures that the target is legit and that make
# can figure out how to build it
_D:=$(shell mkdir -p qsub)
qsub/%:
	@if ! make -C${PWD} -n $* >/dev/null 2>/dev/null; then \
		echo "couldn't make -n $* -- impossible target" 1>&2; \
		exit 1; \
	fi
	@mkdir -p ${@D}				# e.g., qsub/pset42/aa.ids
	echo "make -C${PWD} $*" \
	| ${QSUB} -N$* -ogoose.gene.com:${PWD}/$@.out -egoose.gene.com:${PWD}/$@.err >$@ 2>&1
	@cat $@

#qdel:
#	qstat -urkh | grep '^[0-9]' | cut -f1 -d. | xargs -t qdel



%-split100: %.ids
	mkdir "$*"
	split -l100 "$<" "$*/"
	${HOME}/opt/bin/rename 's/$$/.ids/' "$*"/??
%-split250: %.ids
	mkdir "$*"
	split -l250 "$<" "$*/"
	${HOME}/opt/bin/rename 's/$$/.ids/' "$*"/??
%-split500: %.ids
	mkdir "$*"
	split -l500 "$<" "$*/"
	${HOME}/opt/bin/rename 's/$$/.ids/' "$*"/??



# gzip
%.gz:: %
	gzip $<
%:: %.gz
	gzip -d $<


env:
	env >$@ 2>&1


# Generic cleaning rules
.PHONY: clean cleaner cleanest
clean:
	/bin/rm -f *~ *.bak
	/bin/rm -fr *.err
