include ../common.mk
include ../local.mk
include ../params.mk

default all: sst.log

ifndef SSTPASS
$(warning SSTPASS isn't set ) 	#'
endif



## SST/GENENGENES LOADING
## load sst sequences into Unison
GenenGenes.load : GenenGenes.fa
	grep -v ^ERROR: $< | load-pseq --verbose -oGenenGenes -ffasta - >$@.err 2>&1
	/bin/mv -f $@.err $@
GenenGenes.fa: GenenGenes.proids
	sed -e 's/^/ssp.PRO/' <$< | ssh geneland xargs -tn100 /usr/local/seq/bin/getseq -F >$@.tmp 2>$@.err
	/bin/mv -f $@.err $@; /bin/mv -f $@.tmp $@
GenenGenes.proids:
	gg-proids-to-load >$@.tmp 2>$@.err
	/bin/mv -f $@.err $@; /bin/mv $@.tmp $@
	@wc -l $@


## import sst unq-pro-dna and related tables
sst.log: sst.sql
	(time -p psql -Uunison -qf $<) >$@.err 2>&1
	/bin/mv -f $@.err $@

.PRECIOUS: sst.sql
sst.sql:
	(time -p ./sst-import >$@.tmp) 2>$@.err \
	&& /bin/mv -f $@.err $@.log && /bin/mv -f $@.tmp $@


cleaner:: clean
	/bin/rm -f sst.sql*
cleanest:: cleaner
	/bin/rm -f sst.log*
