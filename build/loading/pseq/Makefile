# loading/pseq/Makefile -- loads sequences sources into Unison
# $Id: Makefile,v 1.13 2005/09/16 04:25:23 rkh Exp $

# This makefile coordinates the loading of sequences into the Unison pseq
# table for UniProt, PDB, RefSeq, Derwent/Geneseq (proprietary), and
# Genentech's internal GenenGenes/SST.


include ../common.mk
include ../local.mk
include ../params.mk


ORIGINS:=ensembl uniprot_sprot uniprot_trembl PDB refseq
ifeq "$(shell hostname -d)" "gene.com"
ORIGINS+=geneseq
endif

default all: $(addsuffix .load,${ORIGINS})
ifeq "$(shell hostname -d)" "gene.com"
	@echo ##########################################################
	@echo ## REMINDER: you must make GenenGenes.load manually.    ##
	@echo ##########################################################
endif




## CCDS
ccds-human.load: ${CCDS_HUMAN_PATH}
	gzip -cdq $< | time -p load-pseq --verbose -oCCDS/Human -ffasta -t9606 - >$@.err 2>&1
	/bin/mv -f $@.err $@


## ENSEMBL
ENSEMBL_SPECIES:=chimp cow fly human mouse rat zebrafish
.PHONY: ensembl.load
ensembl.load: $(foreach S,${ENSEMBL_SPECIES},ensembl-$S.load)
ensembl-chimp.load: $(wildcard ${ENSEMBL_DIR}/current_chimp/data/fasta/pep/*.pep.fa.gz)
	gzip -cdq $< | time -p load-pseq --verbose -oEnsembl/Chimp -ffasta -t9598 - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-cow.load: $(wildcard ${ENSEMBL_DIR}/current_cow/data/fasta/pep/*.pep.fa.gz)
	gzip -cdq $< | time -p load-pseq --verbose -oEnsembl/Cow -ffasta -t9598 - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-fly.load: $(wildcard ${ENSEMBL_DIR}/current_fly/data/fasta/pep/*.pep.fa.gz)
	gzip -cdq $< | time -p load-pseq --verbose -oEnsembl/Fly -ffasta -t7227 - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-human.load: $(wildcard ${ENSEMBL_DIR}/current_human/data/fasta/pep/*.pep.fa.gz)
	gzip -cdq $< | time -p load-pseq --verbose -oEnsembl/Human -ffasta -t9606 - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-mouse.load: $(wildcard ${ENSEMBL_DIR}/current_mouse/data/fasta/pep/*.pep.fa.gz)
	gzip -cdq $< | time -p load-pseq --verbose -oEnsembl/Mouse -ffasta -t10090 - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-rat.load: $(wildcard ${ENSEMBL_DIR}/current_rat/data/fasta/pep/*.pep.fa.gz)
	gzip -cdq $< | time -p load-pseq --verbose -oEnsembl/Rat -ffasta -t10116 - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-zebrafish.load: $(wildcard ${ENSEMBL_DIR}/current_zebrafish/data/fasta/pep/*.pep.fa.gz)
	gzip -cdq $< | time -p load-pseq --verbose -oEnsembl/Zebrafish -ffasta -t7955 - >$@.err 2>&1
	/bin/mv -f $@.err $@


## HUGE & ROUGE
huge.load: %.load: ${HUGE_DIR}/peplib.kiaa2038.tfa
	time -p load-pseq -t9606 --verbose -oHUGE -ffasta $< >$@.err 2>&1
	/bin/mv -f $@.err $@
rouge.load: %.load: ${ROUGE_DIR}/peplib_050401
	time -p load-pseq -t10090 --verbose -oROUGE -ffasta $< >$@.err 2>&1
	/bin/mv -f $@.err $@


## PDB
PDB.load:
	(time -p find ${PDB_DIR} -type f -name \*.pdb \
	| pdb2fa 2>/dev/null \
	| load-pseq --verbose -oPDB -ffasta - ) >$@.err 2>&1 2>&1 
	/bin/mv -f $@.err $@


## REFSEQ
RCPs:=$(wildcard ${REFSEQ_DIR}/complete[0-9]*gpff.gz)
RCPs:=$(subst ${REFSEQ_DIR}/,refseq/,${RCPs})
RCPs:=$(subst .protein.gpff.gz,.load,${RCPs})
refseq.load: ${RCPs}
refseq/%.load: ${REFSEQ_DIR}/%.protein.gpff.gz
	/bin/mkdir -p ${@D}
	time -p load-pseq --verbose -oRefSeq -fgenbank $< >$@.err 2>&1
	/bin/mv -f $@.err $@


## UNIPROT LOADING
uniprot: uniprot_sprot.load uniprot_trembl.load 
uniprot_sprot.load: ${UNIPROT_DIR}/uniprot_sprot.dat.gz
	gzip -cdq $< | time -p load-pseq --verbose -oUniProtKB/Swiss-Prot -fswiss - >$@.err 2>&1
	/bin/mv -f $@.err $@
uniprot_trembl.load: ${UNIPROT_DIR}/uniprot_trembl.dat.gz
	gzip -cdq $< | time -p load-pseq --verbose -oUniProtKB/TrEMBL -fswiss - >$@.err 2>&1
	/bin/mv -f $@.err $@




## TODO: develop fall-through to download files as needed.  Presumably
## this would happen via a vpath to existing files.


########################################################################
## PROPRIETARY SOURCES FOLLOW
########################################################################


## DERWENT/GENESEQ
GENESEQs:=$(notdir $(wildcard ${GENESEQ_DIR}/GENESEQP*.tar.gz) $(wildcard ${GENESEQ_DIR}/AA-GENESEQ*))
.PHONY: geneseq.load
geneseq.load: $(addprefix geneseq/, $(addsuffix .load,${GENESEQs}))
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
## All Genentech-specific stuff will be moved out of common
## Unison areas soon. 
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
	/bin/rm -fr data



########################################################################## 
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
	/bin/mv -f $@.err $@
