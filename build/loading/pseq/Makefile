# eg$ PGPASSWORD=blah make uniprot.load

default all:
	@echo "no default target" 1>&2; exit 1

include ../defaults.mk

_D:=$(shell mkdir -p data logs)

vpath %.fa .


.PHONY: all.load
all.load: uniprot.load PDB.load GenenGenes.load refseq.load
#NOTE: geneseq.load must be done on geneland


## UNIPROT LOADING
UNIPROT_URL:=ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete
uniprot.load: uniprot_sprot.load uniprot_trembl.load 
uniprot_sprot.load: data/uniprot_sprot.dat.gz
	gzip -cdq $< | load-pseq --verbose -oUniprot -fswiss - >$@.err 2>&1
	/bin/mv -f $@.err $@.log; touch $@
uniprot_trembl.load: data/uniprot_trembl.dat.gz
	gzip -cdq $< | load-pseq --verbose -oUniprot/TrEMBL -fswiss - >$@.err 2>&1
	/bin/mv -f $@.err $@.log; touch $@
data/uniprot_sprot.dat.gz data/uniprot_trembl.dat.gz:
	wget -O"$@.tmp" ${UNIPROT_URL}/${@F}
	/bin/mv "$@.tmp" "$@"


## PDB
PDBDIR=/gne/compbio/share/pdb/divided.pdb
PDB.load:
	(time -p find ${PDBDIR} -type f -name \*.pdb \
	| pdb2fa 2>/dev/null \
	| load-pseq --verbose -oPDB -ffasta - ) >$@.log 2>&1 2>&1 
	/bin/mv -f $@.log $@


## SST/GENENGENES LOADING
GenenGenes.load : data/GenenGenes.fa
	load-pseq --verbose -oGenenGenes -ffasta $< >$@.err 2>&1
	/bin/mv -f $@.err $@
data/GenenGenes.fa: data/GenenGenes.proids
	sed -e 's/^/ssp.PRO/' <$< | xargs -tn100 /usr/local/seq/bin/getseq -F >$@.tmp 2>$@.err
	/bin/mv -f $@.err $@.log; /bin/mv $@.tmp $@
data/GenenGenes.proids:
	gg-proids-to-load >$@.tmp 2>$@.err
	/bin/mv -f $@.err $@.log; /bin/mv $@.tmp $@
	@wc -l $@


## REFSEQ
REFSEQ_DIR:=/gne/compbio/share/refseq
#refseq.load: $(foreach N,$(shell perl -le 'print $$_ for 1..59' | grep -v ^40),refseq/complete$N.log)
RCPs:=$(wildcard /gne/compbio/share/refseq/complete[0-9]*gpff.gz)
RCPs:=$(subst ${REFSEQ_DIR}/,refseq/,${RCPs})
RCPs:=$(subst .protein.gpff.gz,.log,${RCPs})
refseq.load: ${RCPs}
refseq/%.log: ${REFSEQ_DIR}/%.protein.gpff.gz
	/bin/mkdir -p ${@D}
	load-pseq --verbose -oRefSeq -fgenbank $< >$@.err 2>&1
	/bin/mv -f $@.err $@



## DERWENT/GENESEQ
## MUST BE DONE ON GENELAND!
GENESEQ_DIR:=/usr/seqdb_nb/geneseq/Aa
GENESEQs:=$(notdir $(basename $(wildcard ${GENESEQ_DIR}/AA*.DAT)))
.PHONY: geneseq
geneseq: $(addprefix geneseq/, $(addsuffix .log,${GENESEQs}))
geneseq/%.log: ${GENESEQ_DIR}/%.DAT
	(echo "# Loading geneseq $?"; \
	 time -p geneseq2fa $? | load-pseq -ffasta -oGeneseq -v -) >$@.err 2>&1
	/bin/mv -f $@.err $@


## UNIGENE
#SPECIES:=Hs Mm Rn Cel
SPECIES:=Hs
#%.load: %




## MISC OTHERS
kabat.load: /usr/seqdb/blast/kabatpro
	load-pseq --verbose -okabat -ffasta $< >$@.err 2>&1

proteome.load: /usr/seqdb/blast/proteome
	load-pseq --verbose -oProteome -ffasta $< >$@.err 2>&1

sugen.load: /home/skelly/geneland/seq/kinase/sugen/sugen_kinase_all.fasta
	load-pseq --verbose -oSugen -ffasta $< >$@.err 2>&1

# swiss-prot is subsumed by uniprot and I no longer load this
sprot%.load : ${COMPBIO}/share/swiss-prot/sprot%.dat
	load-pseq --verbose -oSwiss-Prot -fswiss $< >$@.err 2>&1
	/bin/mv -f $@.err $@.log; touch $@



cleaner:: clean
	/bin/rm -f *.0
cleanest:: cleaner
	/bin/rm -f *.log
	/bin/rm -fr data logs
