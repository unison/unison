# -*-Makefile-*-

.PHONY: FORCE

SHELL:=bash #$(shell which bash)
PATH:=../../bin:${PATH}
#BDB:=/usr/local/seq/share/blast/aa
BDB:=/apps/compbio/share/seqdb
PDBDIR:=/usr/local/seq/share/mirrors/ftp.rcsb.org/pub/pdb/data/structures/divided/pdb


SOURCES:=
ifeq (${PLATFORM},alpha-osf1-5.1)
SOURCES+=spdi pdb sprot
SOURCES+=incyte pred ensembl nr patent proteome dblast hum
else
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


all: $(addsuffix .log,$(addprefix log/, ${SOURCES}))

test:
	make -f bin/load.mf all TEST=1


.PRECIOUS: load-pdb.log load-spdi.log load-ensembl.log load-ipi.log load-sprot.log
.PRECIOUS: load-incyte.log load-%.log load-p2templates.log

vpath % ${BDB}


log/curagen.log : log/%.log : ${BDB}/Curagen_Protein
	${FACAT} $^ | load-fasta -Uadmin --nomd5 --noalias -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@
log/dblast.log : log/%.log : ${BDB}/dblast ${BDB}/dblast.new
	${FACAT} $^ | load-fasta -Uadmin --nomd5 --noalias -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@
log/hum.log : log/%.log : ${BDB}/hum.pro
	${FACAT} $^ | load-fasta -Uadmin --nomd5 --noalias -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@
log/ipi.log : log/%.log : ${BDB}/ipi.HUMAN.fasta ${BDB}/ipi.MOUSE.fasta
	${FACAT} $^ | load-fasta -Uadmin --nomd5 --noalias -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@
log/mus.log : log/%.log : ${BDB}/mus.pro
	${FACAT} $^ | load-fasta -Uadmin --nomd5 --noalias -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@
log/ncbi.log : log/%.log : ${BDB}/ncbi.pro.human ${BDB}/ncbi.pro.mouse
	${FACAT} $^ | load-fasta -Uadmin --nomd5 --noalias -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@
log/sprot.log : log/%.log : ${BDB}/sprot.fas
	${FACAT} $^ | load-fasta -Uadmin --nomd5 --noalias -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@
log/%.log : ${BDB}/%
	${FACAT} $^ | load-fasta -Uadmin --nomd5 --noalias -o$* >$@.0 2>&1
	/bin/mv -f $@.0 $@



#load-p2templates.log : load-%.log : p2templates.ls
#	load-p2template <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-curagen.log: Curagen_Protein
#	load-fasta -Uadmin --nomd5 --noalias -oPDB <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-pdb.log: pdb
#	load-fasta -Uadmin --nomd5 --noalias -oPDB <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-spdi.log: load-%.log: spdi.fa
#	load-fasta -Uadmin --nomd5 --noalias -o$* <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-sst.log: /usr/seqdb3/sst/sstpro
#	load-fasta -Uadmin --nomd5 --noalias -oSPDI <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-ensembl.log : load-%.log : ${BDB}/ens.known ${BDB}/ens.novel
#	${FACAT} $^ | load-fasta -Uadmin --nomd5 --noalias -o$* >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-ipi.log : load-%.log : ${BDB}/ipi.HUMAN ${BDB}/ipi.MOUSE
#	${FACAT} $^ | load-fasta -Uadmin --nomd5 --noalias -o$* >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-sprot.log : load-%.log : ${BDB}/sprot
#	load-fasta -Uadmin --nomd5 --noalias -oswiss-prot <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-incyte.log: /usr/incyte/data/blast/databases/FdnFLProteinOct02 /usr/incyte/data/blast/databases/FdnNRAltFLProteinOct02
#	${FACAT} $^ | load-fasta -Uadmin --nomd5 --noalias -oIncyte >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-rps.log: /usr/seqdb/blast/rps-proteins.fasta
#	load-fasta -Uadmin --nomd5 --noalias -o$< <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-fantom.log: /usr/seqdb/blast/fantom.pro
#	load-fasta -Uadmin --nomd5 --noalias -oFANTOM <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-proteome.log: /usr/local/seq/share/blast/aa/proteome
#	load-fasta -Uadmin --nomd5 --noalias -oProteome <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-hum.log: /usr/local/seq/share/blast/aa/hum
#	load-fasta -Uadmin --nomd5 --noalias -ohum <$< >$@.0 2>&1
#	/bin/mv -f $@.0 $@
#load-dblast.log: /usr/local/seq/share/blast/aa/dblast
#	load-fasta -Uadmin --nomd5 --noalias -odblast <$< >$@.0 2>&1
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
