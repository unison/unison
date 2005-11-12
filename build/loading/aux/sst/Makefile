include ../common.mk
include ../local.mk
include ../params.mk


default all: sst.log

ifndef SSTPASS
$(warning SSTPASS isn't set ) 	#'
endif



## SST/GENENGENES LOADING
## All Genentech-specific stuff will be moved out of common
## Unison areas soon. 
GenenGenes.load : data/GenenGenes.fa
	grep -v ^ERROR: $< | load-pseq --verbose -oGenenGenes -ffasta - >$@.err 2>&1
	/bin/mv -f $@.err $@
data/GenenGenes.fa: data/GenenGenes.proids
	sed -e 's/^/ssp.PRO/' <$< | ssh geneland xargs -tn100 /usr/local/seq/bin/getseq -F >$@.tmp 2>$@.err
	/bin/mv -f $@.err $@; /bin/mv -f $@.tmp $@
data/GenenGenes.proids:
	gg-proids-to-load >$@.tmp 2>$@.err
	/bin/mv -f $@.err $@; /bin/mv $@.tmp $@
	@wc -l $@


sst.log: sst.sql
	(time -p psql -Uunison -qf sst.sql) >$@.err 2>&1 \
	&& /bin/mv -f $@.err $@

.PRECIOUS: sst.sql
sst.sql:
	(time -p sst-import >$@.tmp) 2>$@.err \
	&& /bin/mv -f $@.err $@.log && /bin/mv -f $@.tmp $@


cleaner:: clean
	/bin/rm -f sst.sql*
cleanest:: cleaner
	/bin/rm -f sst.log*
