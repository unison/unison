# loading/pseq/Makefile -- loads sequences sources into Unison
# $Id$

# This makefile coordinates the loading of sequences into the Unison pseq
# table for UniProt, PDB, RefSeq, Derwent/Geneseq (proprietary), and
# Genentech's internal GenenGenes/SST.


ORIGINS:=uniprot_sprot uniprot_trembl PDB refseq geneseq

default all: $(addsuffix .load,${ORIGINS})
# 'make GenenGenes.load' manually on geneland


include ../common.mk

_D:=$(shell mkdir -p data logs)
vpath %.fa .


.PHONY: all.load
all.load: uniprot.load PDB.load GenenGenes.load refseq.load


## UNIPROT LOADING
UNIPROT_URL:=ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete
uniprot.load: uniprot_sprot.load uniprot_trembl.load 
uniprot_sprot.load: data/uniprot_sprot.dat.gz
	gzip -cdq $< | time -p load-pseq --verbose -oUniprot -fswiss - >$@.err 2>&1
	/bin/mv -f $@.err $@; touch $@
uniprot_trembl.load: data/uniprot_trembl.dat.gz
	gzip -cdq $< | time -p load-pseq --verbose -oUniprot/TrEMBL -fswiss - >$@.err 2>&1
	/bin/mv -f $@.err $@; touch $@
data/uniprot_sprot.dat.gz data/uniprot_trembl.dat.gz:
	wget -O"$@.tmp" ${UNIPROT_URL}/${@F}
	/bin/mv "$@.tmp" "$@"


## PDB
PDBDIR=/gne/compbio/share/pdb/divided.pdb
PDB.load:
	(time -p find ${PDBDIR} -type f -name \*.pdb \
	| pdb2fa 2>/dev/null \
	| load-pseq --verbose -oPDB -ffasta - ) >$@.err 2>&1 2>&1 
	/bin/mv -f $@.err $@


## REFSEQ
REFSEQ_DIR:=/gne/compbio/share/refseq
#refseq.load: $(foreach N,$(shell perl -le 'print $$_ for 1..59' | grep -v ^40),refseq/complete$N.log)
RCPs:=$(wildcard /gne/compbio/share/refseq/complete[0-9]*gpff.gz)
RCPs:=$(subst ${REFSEQ_DIR}/,refseq/,${RCPs})
RCPs:=$(subst .protein.gpff.gz,.load,${RCPs})
refseq.load: ${RCPs}
refseq/%.load: ${REFSEQ_DIR}/%.protein.gpff.gz
	/bin/mkdir -p ${@D}
	time -p load-pseq --verbose -oRefSeq -fgenbank $< >$@.err 2>&1
	/bin/mv -f $@.err $@



## DERWENT/GENESEQ
GENESEQ_DIR:=/gne/compbio/share/geneseq
GENESEQs:=$(notdir $(wildcard ${GENESEQ_DIR}/GENESEQP*.tar.gz) $(wildcard ${GENESEQ_DIR}/AA-GENESEQ*))
.PHONY: geneseq
geneseq: $(addprefix geneseq/, $(addsuffix .load,${GENESEQs}))
geneseq/%.load: ${GENESEQ_DIR}/%
	(time -p tar -Oxzf- <$< | geneseq2fa - | load-pseq -ffasta -oGeneseq -v -) >$@.err 2>&1
	/bin/mv -f $@.err $@
geneseq/AA-GENESEQ.update.gz.load: ${GENESEQ_DIR}/AA-GENESEQ.update.gz
	(time -p gzip -cdq <$< | geneseq2fa - | load-pseq -ffasta -oGeneseq -v -) >$@.err 2>&1
	/bin/mv -f $@.err $@
#geneseq/%.load: ${GENESEQ_DIR}/%.DAT
#	(time -p geneseq2fa $? | load-pseq -ffasta -oGeneseq -v -) >$@.err 2>&1
#	/bin/mv -f $@.err $@


## SST/GENENGENES LOADING
GenenGenes.load : data/GenenGenes.fa
	grep -v ^ERROR: $< | load-pseq --verbose -oGenenGenes -ffasta - >$@.err 2>&1
	/bin/mv -f $@.err $@
data/GenenGenes.fa: data/GenenGenes.proids
	# This must be done on geneland!
	sed -e 's/^/ssp.PRO/' <$< | xargs -tn100 /usr/local/seq/bin/getseq -F >$@.tmp 2>$@.err
	/bin/mv -f $@.err $@; /bin/mv $@.tmp $@
data/GenenGenes.proids:
	gg-proids-to-load >$@.tmp 2>$@.err
	/bin/mv -f $@.err $@; /bin/mv $@.tmp $@
	@wc -l $@



cleaner:: clean
	/bin/rm -f *.0
cleanest:: cleaner
	/bin/rm -f *.load
	/bin/rm -fr data logs


######################## ABANDONED AND INCOMPLETE ######################## 

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



