# -*-Makefile-*-

.PHONY: FORCE

SHELL:=bash #$(shell which bash)
PATH:=../../sbin:${PATH}


SOURCES:=
ifeq (${PLATFORM},alpha-osf1-5.1)
SDB:=/usr/local/seq/share/seqdb/aa
BDB:=${SDB}
SOURCES+=spdi pdb sprot
SOURCES+=incyte pred ensembl nr patent proteome dblast hum
else
PDBDIR:=/apps/compbio/share/mirrors/ftp.rcsb.org/pub/pdb/data/structures/divided/pdb
SDB:=/apps/compbio/share/seqdb/aa
BDB:=${SDB}
SOURCES+=p2templates
endif

SOURCES:=curagen dblast hum igpro ipi mus ncbi nr pdb proteome sprot viruspro


ifdef TEST
HEAD:=head -qn50
FACAT:=head -qn500
PHEAD:=| ${HEAD}
else
HEAD:=cat
FACAT:=cat
PHEAD:=
endif

LOAD_FASTA:=load-fasta -Uunison -dcsb-dev



all: $(addsuffix .log,${SOURCES})

test:
	make -f bin/load.mf all TEST=1


.PRECIOUS: load-pdb.log load-spdi.log load-ensembl.log load-ipi.log load-sprot.log
.PRECIOUS: load-incyte.log load-%.log load-p2templates.log

vpath % ${BDB}


curagen.log : %.log : ${BDB}/Curagen_Protein
	${FACAT} $^ | ${LOAD_FASTA} -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@
dblast.log : %.log : ${BDB}/dblast ${BDB}/dblast.new
	${FACAT} $^ | ${LOAD_FASTA} -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@
hum.log : %.log : ${BDB}/hum.pro
	${FACAT} $^ | ${LOAD_FASTA} -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@
ipi.log : %.log : ${BDB}/ipi.HUMAN.fasta ${BDB}/ipi.MOUSE.fasta
	${FACAT} $^ | ${LOAD_FASTA} -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@
mus.log : %.log : ${BDB}/mus.pro
	${FACAT} $^ | ${LOAD_FASTA} -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@
ncbi.log : %.log : ${BDB}/ncbi.pro.human ${BDB}/ncbi.pro.mouse
	${FACAT} $^ | ${LOAD_FASTA} -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@
sprot.log : %.log : ${BDB}/sprot.fas
	${FACAT} $^ | ${LOAD_FASTA} -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@
spdi.log : %.log : ${BDB}/sst.fa
	${FACAT} $^ | ${LOAD_FASTA} -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@
%.log : ${BDB}/%
	${FACAT} $^ | ${LOAD_FASTA} -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@



#load-p2templates.log : load-%.log : p2templates.ls
#	load-p2template <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-curagen.log: Curagen_Protein
#	${LOAD_FASTA} -oPDB <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-pdb.log: pdb
#	${LOAD_FASTA} -oPDB <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-spdi.log: load-%.log: spdi.fa
#	${LOAD_FASTA} -o$* <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-sst.log: /usr/seqdb3/sst/sstpro
#	${LOAD_FASTA} -oSPDI <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-ensembl.log : load-%.log : ${BDB}/ens.known ${BDB}/ens.novel
#	${FACAT} $^ | ${LOAD_FASTA} -o$* >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-ipi.log : load-%.log : ${BDB}/ipi.HUMAN ${BDB}/ipi.MOUSE
#	${FACAT} $^ | ${LOAD_FASTA} -o$* >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-sprot.log : load-%.log : ${BDB}/sprot
#	${LOAD_FASTA} -oswiss-prot <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-incyte.log: /usr/incyte/data/blast/databases/FdnFLProteinOct02 /usr/incyte/data/blast/databases/FdnNRAltFLProteinOct02
#	${FACAT} $^ | ${LOAD_FASTA} -oIncyte >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-rps.log: /usr/seqdb/blast/rps-proteins.fasta
#	${LOAD_FASTA} -o$< <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-fantom.log: /usr/seqdb/blast/fantom.pro
#	${LOAD_FASTA} -oFANTOM <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-proteome.log: /usr/local/seq/share/blast/aa/proteome
#	${LOAD_FASTA} -oProteome <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-hum.log: /usr/local/seq/share/blast/aa/hum
#	${LOAD_FASTA} -ohum <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-dblast.log: /usr/local/seq/share/blast/aa/dblast
#	${LOAD_FASTA} -odblast <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@






pdb.fa:
	find ${PDBDIR} -name \*.ent.Z ${PHEAD} ${PHEAD} | pdb2fa >$@.tmp
	/bin/mv -f $@.tmp $@

p2templates.ls: FORCE
	find /opt/prospect/data/templ* -name \*.xml ${PHEAD} >$@
sel.sql:
	(cat ~/.sqlplus; echo 'select primarydnaid from unq;'; echo 'exit;') >$@
spdi.ids: sel.sql FORCE
	sqlplus /@bioprd1 @$< | perl -lane 'print $$F[0] if /^\s+\d+s*$$/' >$@
	wc -l $@


schema.sql:
	pg_dump -htd-sprog unison -s >$@
init.sql:
	@/bin/rm $@.tmp
	pg_dump -ad -htd-sprog unison -tporigin >>$@.tmp
	pg_dump -ad -htd-sprog unison -tpftype >>$@.tmp
	pg_dump -ad -htd-sprog unison -tpset >>$@.tmp
	/bin/mv $@.tmp $@


tmdetect-undone.ids: FORCE
	psql -htd-sprog -dunison -q -c'select pseq_id from pseq except select pseq_id from only pfeature where pftype_id=4 or pftype_id=5 or pftype_id=6 order by pseq_id' >$@.tmp
	/bin/mv -f $@.tmp $@
sigpredict-undone.ids: FORCE
	psql -htd-sprog -dunison -q -c'select pseq_id from pseq except select pseq_id from only pseqprop' >$@.tmp
	/bin/mv -f $@.tmp $@

clean:
	/bin/rm -f *~ *.bak
cleaner: clean
	/bin/rm -f *.0
cleanest: cleaner
	/bin/rm -f *.log
