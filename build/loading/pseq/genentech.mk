## genentech.mk

ifndef SSTPASS
$(warning WARNING: SSTPASS isn't set ) 	#'
endif

## SST/GENENGENES LOADING
## load sst sequences into Unison
genengenes.load : genengenes.fa
	grep -v ^ERROR: $< | load-pseq --verbose -oGenenGenes -ffasta - >$@.err 2>&1
	/bin/mv -f $@.err $@
genengenes.fa: genengenes.proids
	sed -e 's/^/ssp.PRO/' <$< | ssh geneland xargs -n100 /usr/local/seq/bin/getseq -F | grep -v ^[[:space:]] >$@.tmp 2>$@.err
	/bin/mv -f $@.err $@; /bin/mv -f $@.tmp $@
genengenes.proids:
	${UNISON_HOME}/build/loading/aux/sst/gg-proids-to-load >$@.tmp 2>$@.err
	/bin/mv -f $@.err $@; /bin/mv $@.tmp $@
	@wc -l $@


## import sst unq-pro-dna and related tables
sst.log: sst.sql
	(time -p psql -Uunison -qf $<) >$@.err 2>&1
	/bin/mv -f $@.err $@

.PRECIOUS: sst.sql
sst.sql:
	(time -p ${UNISON_HOME}/unison/sst-import >$@.tmp) 2>$@.err \
	&& /bin/mv -f $@.err $@.log && /bin/mv -f $@.tmp $@


cleaner:: clean
	/bin/rm -f sst.sql*
cleanest:: cleaner
	/bin/rm -f sst.log*
