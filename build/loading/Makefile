.SUFFIXES:

include defaults.mk

all: pseq pseqset

external: scop 

aux: affyannot

run: pfbigpi pftmdetect

DIRS:=affyannot blat pahmm paprospect2 papseq pappsm pfbigpi pftmdetect plocus pmhmm ppintx pseq pseqprop sst

tax.log: pseq.log
	psql -Uunison -af ../sql/create-pao-tax.sql >$@.err 2>&1
	../sbin/update_tax_ids.pl -Uunison -ar >>$@.err 2>&1
	/bin/mv -f $@.err $@

psets.log: tax.log
	psql -Uunison -ac 'select update_uni_psets()' >$@.err 2>&1
	psql -Uunison -ac 'select update_species_psets()' >>$@.err 2>&1
	psql -Uunison -qf ../sql/pset0.sql >>$@.err 2>&1
	/bin/mv -f $@.err $@


%.log: %
	make -C $* pset42.load >$@.err 2>&1
	/bin/mv $@.err $@


# dependencies
pcluster.log: blat.log


clean cleaner cleanest::
	@for dir in ${DIRS}; do make -C $$dir $@; done
