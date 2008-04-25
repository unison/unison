# loading/pseq/Makefile -- loads sequences sources into Unison
# $Id: Makefile,v 1.26 2007/06/04 18:02:35 mukhyala Exp $

# This makefile coordinates the loading of sequences into the Unison pseq
# table for UniProt, Ensembl, PDB, RefSeq, Derwent/Geneseq (proprietary), and
# Genentech's internal GenenGenes/SST.

default all: update

include ../common.mk
include ../local.mk
include ../params.mk

ORIGINS:=ensembl uniprot_sprot uniprot_trembl PDB refseq

ifeq "${GNE}" "1"
ORIGINS+=genengenes
include genentech.mk

ifeq "$(shell test -d ${GENESEQ_DIR}; echo $$?)" "0"
$(warning NOTICE: enabling Geneseq/Derwent loading from ${GENESEQ_DIR})
ORIGINS+=geneseq
endif

endif


update: $(addsuffix .load,${ORIGINS})


## CCDS
ccds-human.load: ${CCDS_HUMAN_PATH}
	gzip -cdq $< | time -p load-pseq --deprecate -vv -oCCDS/Human -ffasta -t9606 - >$@.err 2>&1
	/bin/mv -f $@.err $@


## ENSEMBL
ENSEMBL_SPECIES:=chimp cow fly human mouse rat zebrafish
.PHONY: ensembl.load
ensembl.load: $(foreach S,${ENSEMBL_SPECIES},ensembl-$S.load) $(foreach S,${ENSEMBL_SPECIES},ensembl-$S-ai.load)
ensembl-chimp.load: $(wildcard ${ENSEMBL_DIR}/current_pan_troglodytes/data/fasta/pep/*.pep.fa.gz) 
	gzip -cdq $< | time -p load-pseq --deprecate -vv -oEnsembl/Chimp -ffasta -t9598 -V$(<F:Pan_troglodytes.%.pep.fa.gz=%) - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-chimp-ai.load: $(wildcard ${ENSEMBL_DIR}/current_pan_troglodytes/data/fasta/pep/*.pep.abinitio.fa.gz)
	gzip -cdq $< | time -p load-pseq --deprecate -vv -o'Ensembl/Chimp (ab initio)' -ffasta -t9598 -V$(<F:Pan_troglodytes.%.pep.abinitio.fa.gz=%) - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-cow.load: $(wildcard ${ENSEMBL_DIR}/current_bos_taurus/data/fasta/pep/*.pep.fa.gz)
	gzip -cdq $< | time -p load-pseq --deprecate -vv -oEnsembl/Cow -ffasta -t9913 -V$(<F:Bos_taurus.%.pep.fa.gz=%) - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-cow-ai.load: $(wildcard ${ENSEMBL_DIR}/current_bos_taurus/data/fasta/pep/*.pep.abinitio.fa.gz)
	gzip -cdq $< | time -p load-pseq --deprecate -vv -o'Ensembl/Cow (ab initio)' -ffasta -t9913 -V$(<F:Bos_taurus.%.pep.abinitio.fa.gz=%) - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-fly.load: $(wildcard ${ENSEMBL_DIR}/current_drosophila_melanogaster/data/fasta/pep/*.pep.fa.gz)
	gzip -cdq $< | time -p load-pseq --deprecate -vv -oEnsembl/Fly -ffasta -t7227 -V$(<F:Drosophila_melanogaster.%.pep.fa.gz=%) - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-fly-ai.load: $(wildcard ${ENSEMBL_DIR}/current_drosophila_melanogaster/data/fasta/pep/*.pep.abinitio.fa.gz)
	gzip -cdq $< | time -p load-pseq --deprecate -vv -o'Ensembl/Fly (ab initio)' -ffasta -t7227 -V$(<F:Drosophila_melanogaster.%.pep.abinitio.fa.gz=%) - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-human.load: $(wildcard ${ENSEMBL_DIR}/current_homo_sapiens/data/fasta/pep/*.pep.fa.gz)
	gzip -cdq $< | time -p load-pseq --deprecate -vv -oEnsembl/Human -ffasta -t9606 -V$(<F:Homo_sapiens.%.pep.fa.gz=%) - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-human-ai.load: $(wildcard ${ENSEMBL_DIR}/current_homo_sapiens/data/fasta/pep/*.pep.abinitio.fa.gz)
	gzip -cdq $< | time -p load-pseq --deprecate -vv -o'Ensembl/Human (ab initio)' -ffasta -t9606 -V$(<F:Homo_sapiens.%.pep.abinitio.fa.gz=%) - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-mouse.load: $(wildcard ${ENSEMBL_DIR}/current_mus_musculus/data/fasta/pep/*.pep.fa.gz)
	gzip -cdq $< | time -p load-pseq --deprecate -vv -oEnsembl/Mouse -ffasta -t10090 -V$(<F:Mus_musculus.%.pep.fa.gz=%) - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-mouse-ai.load: $(wildcard ${ENSEMBL_DIR}/current_mus_musculus/data/fasta/pep/*.pep.abinitio.fa.gz)
	gzip -cdq $< | time -p load-pseq --deprecate -vv -o'Ensembl/Mouse (ab initio)' -ffasta -t10090 -V$(<F:Mus_musculus.%.pep.abinitio.fa.gz=%) - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-rat.load: $(wildcard ${ENSEMBL_DIR}/current_rattus_norvegicus/data/fasta/pep/*.pep.fa.gz)
	gzip -cdq $< | time -p load-pseq --deprecate -vv -oEnsembl/Rat -ffasta -t10116 -V$(<F:Rattus_norvegicus.%.pep.fa.gz=%) - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-rat-ai.load: $(wildcard ${ENSEMBL_DIR}/current_rattus_norvegicus/data/fasta/pep/*.pep.abinitio.fa.gz)
	gzip -cdq $< | time -p load-pseq --deprecate -vv -o'Ensembl/Rat (ab initio)' -ffasta -t10116 -V$(<F:Rattus_norvegicus.%.pep.abinitio.fa.gz=%) - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-zebrafish.load: $(wildcard ${ENSEMBL_DIR}/current_danio_rerio/data/fasta/pep/*.pep.fa.gz)
	gzip -cdq $< | time -p load-pseq --deprecate -vv -oEnsembl/Zebrafish -ffasta -t7955 -V$(<F:Danio_rerio.%.pep.fa.gz=%) - >$@.err 2>&1
	/bin/mv -f $@.err $@
ensembl-zebrafish-ai.load: $(wildcard ${ENSEMBL_DIR}/current_danio_rerio/data/fasta/pep/*.pep.abinitio.fa.gz)
	gzip -cdq $< | time -p load-pseq --deprecate -vv -o'Ensembl/Zebrafish (ab initio)' -ffasta -t7955 -V$(<F:Danio_rerio.%.pep.abinitio.fa.gz=%) - >$@.err 2>&1
	/bin/mv -f $@.err $@


## HUGE & ROUGE
huge.load: %.load: ${HUGE_DIR}/peplib.kiaa2038.tfa
	time -p load-pseq --deprecate -t9606 -vv -oHUGE -ffasta $< >$@.err 2>&1
	/bin/mv -f $@.err $@
rouge.load: %.load: ${ROUGE_DIR}/peplib_050401
	time -p load-pseq --deprecate -t10090 -vv -oROUGE -ffasta $< >$@.err 2>&1
	/bin/mv -f $@.err $@


## NR
nr.load: ${NR_FA}
	(time -p load-pseq --deprecate -vv -ffasta -onr    $<) >$@.err 2>&1
	/bin/mv -f $@.err $@


## PATAA
pataa.load: ${PATAA_FA}
	(time -p load-pseq --deprecate -v -ffasta -opataa --infer-tax-id $<) >$@.err 2>&1
	/bin/mv -f $@.err $@


## PDB
PDB.load:
	(time -p find ${PDB_DIR} -type f -name \*.pdb \
	| pdb2fa 2>/dev/null \
	| load-pseq --deprecate -v -oPDB -ffasta - ) >$@.err 2>&1 2>&1 
	/bin/mv -f $@.err $@


## REFSEQ
## Alias deprecation requires that all sequences of a single origin are
## loaded in single invocation of load-pseq
REFSEQ_RELEASE:=$(patsubst RefSeq-release%.txt,%,$(notdir $(shell /bin/ls -t ${REFSEQ_DIR}/../release-notes/*.txt | head -1)))
refseq.load: $(wildcard ${REFSEQ_DIR}/complete[0-9]*gpff.gz)
	PERL5LIB=../../../perl5:$$PERL5LIB time -p load-pseq --deprecate -vv -fgenbank -oRefSeq --infer-tax-id -V"${REFSEQ_RELEASE}" $^ >$@.err 2>&1
	/bin/mv -f $@.err $@


## UNIPROT LOADING
SPROT_VERSION := `grep Swiss  ${UNIPROT_DIR}/reldate.txt |cut -d' ' -f3`
TrEMBL_VERSION:= `grep TrEMBL ${UNIPROT_DIR}/reldate.txt |cut -d' ' -f3`
uniprot: uniprot_sprot.load uniprot_trembl.load 
uniprot_sprot.load: ${UNIPROT_DIR}/uniprot_sprot.dat.gz
	gzip -cdq $< | PERL5LIB=../../../perl5:$$PERL5LIB time -p load-pseq --deprecate -vv -oUniProtKB/Swiss-Prot -fswiss -V${SPROT_VERSION} - >$@.err 2>&1
	/bin/mv -f $@.err $@
uniprot_trembl.load: ${UNIPROT_DIR}/uniprot_trembl.dat.gz
	gzip -cdq $< |  PERL5LIB=../../../perl5:$$PERL5LIB time -p load-pseq --deprecate -vv -oUniProtKB/TrEMBL -fswiss -V${TrEMBL_VERSION} - >$@.err 2>&1 
	/bin/mv -f $@.err $@




########################################################################
## PROPRIETARY SOURCES FOLLOW
########################################################################


## DERWENT/GENESEQ
## loaded directly from derwent tar'd, gzip'd fasta files
## Their distribution method is inconvenient.
GENESEQ_TARS:=$(wildcard ${GENESEQ_DIR}/GENESEQP*.tar.gz)
GENESEQ_UPDATES:=$(wildcard ${GENESEQ_DIR}/AA-GENESEQ*)
geneseq.load: ${GENESEQ_TARS} ${GENESEQ_UPDATES}
	( ( \
	for tarfile in ${GENESEQ_TARS}; do tar -Ovxz -f $$tarfile; done; \
	gzip -cdq ${GENESEQ_UPDATES} \
	) \
	| geneseq2fa - \
	| load-pseq --deprecate -ffasta -oGeneseq -vv - ) >$@.err 2>&1
	/bin/mv -f $@.err $@

#### Old multi-file loading rules
# alias deprecation requires loading all files from a single origin
# with a single instance of load pseq.
## GENESEQs:=$(notdir $(wildcard ${GENESEQ_DIR}/GENESEQP*.tar.gz) $(wildcard ${GENESEQ_DIR}/AA-GENESEQ*))
## .PHONY: geneseq.load
## geneseq.load: $(addprefix geneseq/, $(addsuffix .load,${GENESEQs}))
## geneseq/%.load: ${GENESEQ_DIR}/%
## 	(time -p tar -Oxzf- <$< | geneseq2fa - | load-pseq -ffasta -oGeneseq -v -) >$@.err 2>&1
## 	/bin/mv -f $@.err $@
## geneseq/AA-GENESEQ.update.gz.load: ${GENESEQ_DIR}/AA-GENESEQ.update.gz
## 	(time -p gzip -cdq <$< | geneseq2fa - | load-pseq -ffasta -oGeneseq -v -) >$@.err 2>&1
## 	/bin/mv -f $@.err $@





cleaner:: clean
	/bin/rm -f *.0
cleanest:: cleaner
	/bin/rm -f *.load
	/bin/rm -fr data
	/bin/rm -f *.fa *.proids



########################################################################## 
######################## ABANDONED AND INCOMPLETE ######################## 

## UNIGENE
#SPECIES:=Hs Mm Rn Cel
SPECIES:=Hs
#%.load: %


## MISC OTHERS
kabat.load: /usr/seqdb/blast/kabatpro
	load-pseq --deprecate -vv -okabat -ffasta $< >$@.err 2>&1

proteome.load: /usr/seqdb/blast/proteome
	load-pseq -vv -oProteome -ffasta $< >$@.err 2>&1

sugen.load: /home/skelly/geneland/seq/kinase/sugen/sugen_kinase_all.fasta
	load-pseq -vv -oSugen -ffasta $< >$@.err 2>&1

cosmic.load: ${COSMIC_DIR}/cosmic.fa
	time -p load-pseq --deprecate -v -ffasta -oCosmic -v  -t9606 $< >$@.err 2>&1
	/bin/mv -f $@.err $@
