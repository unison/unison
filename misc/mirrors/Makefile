.SUFFIXES:
.PHONY: FORCE

############################################################################
# TODO
## * automatically determine download version for pfam, homologene,
## ensembl, and scop
## * separate stanzas into separate files, e.g., sources.d/ensembl.mk
## (but creates a problem that symlinks to makefile will fail unless
## we defined a "top" directory or symlink the include dir.)
##
############################################################################
### CONFIGURATION

# versions -- check these frequently and manually
GRCH_VERSION:=37
HOMOLOGENE_VERSION:=64
MINT_VERSION:=2008-10-01
PFAM_VERSION:=26.0
SCOP_VERSION:=1.73
STRING_VERSION:=7.1

ASTRAL_VERSION:=${SCOP_VERSION}

DBSNP_SPECIES:=				\
	dog_9615	\
	human_9606	\
	mouse_10090	\
	rat_10116

# other config that doesn't change often
ENSEMBL_BASE_URL:=ftp://ftp.ensembl.org/pub
ENSEMBL_RELEASE:=65
ENSEMBL_SPECIES:=				\
	bos_taurus					\
	caenorhabditis_elegans		\
	canis_familiaris			\
	danio_rerio					\
	drosophila_melanogaster		\
	gallus_gallus				\
	homo_sapiens				\
	macaca_mulatta				\
	mus_musculus				\
	pan_troglodytes				\
	rattus_norvegicus			\
	saccharomyces_cerevisiae	\
	xenopus_tropicalis
UNIGENE_SPECIES:= 				\
	Bos_taurus					\
	Caenorhabditis_elegans		\
	Canis_familiaris			\
	Danio_rerio					\
	Drosophila_melanogaster		\
	Gallus_gallus				\
	Homo_sapiens				\
	Macaca_mulatta				\
	Mus_musculus				\
	Rattus_norvegicus
NCBI_SPECIES:=					\
	H_sapiens					\
	Bacteria/Staphylococcus_aureus_aureus_MRSA252	\
	Bacteria/Staphylococcus_aureus_aureus_MSSA476	\
	Bacteria/Staphylococcus_aureus_aureus_MSSA476	\
	Bacteria/Staphylococcus_aureus_COL				\
	Bacteria/Staphylococcus_aureus_COL				\
	Bacteria/Staphylococcus_aureus_JH1				\
	Bacteria/Staphylococcus_aureus_JH1				\
	Bacteria/Staphylococcus_aureus_JH9				\
	Bacteria/Staphylococcus_aureus_JH9				\
	Bacteria/Staphylococcus_aureus_Mu3				\
	Bacteria/Staphylococcus_aureus_Mu50				\
	Bacteria/Staphylococcus_aureus_Mu50				\
	Bacteria/Staphylococcus_aureus_MW2				\
	Bacteria/Staphylococcus_aureus_N315				\
	Bacteria/Staphylococcus_aureus_N315				\
	Bacteria/Staphylococcus_aureus_NCTC_8325		\
	Bacteria/Staphylococcus_aureus_Newman			\
	Bacteria/Staphylococcus_aureus_RF122			\
	Bacteria/Staphylococcus_aureus_USA300			\
	Bacteria/Staphylococcus_aureus_USA300			\
	Bacteria/Staphylococcus_aureus_USA300			\
	Bacteria/Staphylococcus_aureus_USA300			\
	Bacteria/Staphylococcus_aureus_USA300_TCH1516	\
	Bacteria/Staphylococcus_aureus_USA300_TCH1516


WGET=wget -o$@.err -m -np
# -o log
# -m mirror
# -nv not verbose (er, semi quiet)
# -np no parents (don't ascend)
# other options: --limit-rate=1m --waitretry=1


_:=$(shell mkdir -p logs)


default: update


############################################################################
### ASTRAL
### http://astral.berkeley.edu/
UPDATE_TARGETS+=astral
logs/astral.log: FORCE
	${WGET} http://astral.berkeley.edu/scopseq-${ASTRAL_VERSION}


############################################################################
### BLAST STUFF (NBCI)
UPDATE_TARGETS+=nr pataa blast-matrices blast
logs/nr.log: FORCE
	${WGET} ftp://ftp.ncbi.nih.gov/blast/db/nr*
	/bin/mv -f $@.err $@

logs/pataa.log: FORCE
	${WGET} ftp://ftp.ncbi.nih.gov/blast/db/pataa*
	/bin/mv -f $@.err $@

logs/blast-matrices.log: FORCE
	${WGET} ftp://ftp.ncbi.nih.gov/blast/matrices/
	/bin/mv -f $@.err $@

logs/blast.log: logs/nr.log logs/pataa.log logs/blast-matrices.log


############################################################################
### BOWTIE
UPDATE_TARGETS+=bowtie
logs/bowtie.log:
	${WGET} ftp://ftp.cbcb.umd.edu/pub/data/bowtie_indexes/h*.ebwt.zip
	/bin/mv -f $@.err $@


############################################################################
### CCDS
UPDATE_TARGETS+=ccds
logs/ccds.log:
	${WGET} -R archive ftp://ftp.ncbi.nih.gov/pub/CCDS
	/bin/mv -f $@.err $@


############################################################################
### CDD
UPDATE_TARGETS+=cdd
logs/cdd.log: FORCE
	${WGET} ftp://ftp.ncbi.nih.gov/pub/mmdb/cdd/
	/bin/mv -f $@.err $@


############################################################################
### CHEBI
UPDATE_TARGETS+=chebi
logs/chebi.log: FORCE
	${WGET} ftp://ftp.ebi.ac.uk/pub/databases/chebi/README.txt \
			ftp://ftp.ebi.ac.uk/pub/databases/chebi/generic_dumps \
			ftp://ftp.ebi.ac.uk/pub/databases/chebi/ontology \
			ftp://ftp.ebi.ac.uk/pub/databases/chebi/schema.gif \
			ftp://ftp.ebi.ac.uk/pub/databases/chebi/tutorial
	/bin/mv -f $@.err $@


############################################################################
### COSMIC
UPDATE_TARGETS+=cosmic
logs/cosmic.log: FORCE
	${WGET} ftp://ftp.sanger.ac.uk/pub/CGP/cosmic/fasta_files/*_protein.txt -O - >> cosmic.fa
	/bin/mv -f cosmic.fa ftp.sanger.ac.uk/pub/CGP/cosmic/fasta_files
	/bin/mv -f $@.err $@


############################################################################
### DBSNP
UPDATE_TARGETS+=dbsnp
logs/dbsnp.log: $(foreach s,${DBSNP_SPECIES},logs/dbsnp-${s}.log)
	/bin/ls -1 $^ >$@.err
	/bin/mv -f $@.err $@
logs/dbsnp-%.log: FORCE
	${WGET} ftp://ftp.ncbi.nih.gov/snp/organisms/$*/XML
	/bin/mv -f $@.err $@


############################################################################
### DSSP
UPDATE_TARGETS+=dssp
logs/dssp.log:
	rsync -Rrltvz --delete-after rsync://rsync.cmbi.ru.nl/dssp dssp/ >$@.err 2>&1
	/bin/mv -f $@.err $@


############################################################################
### ENSEMBL
ENSEMBL_SUBTARGETS:=$(foreach s,${ENSEMBL_SPECIES},ensembl-${s})
UPDATE_TARGETS+=ensembl ${ENSEMBL_SUBTARGETS}
logs/ensembl.log: $(foreach s,${ENSEMBL_SUBTARGETS},logs/${s}.log)
	/bin/ls -1 $^ >$@.err
	/bin/mv -f $@.err $@

logs/ensembl-%.log: FORCE
	${WGET} \
		${ENSEMBL_BASE_URL}/release-${ENSEMBL_RELEASE}/fasta/homo_sapiens/pep/ \
		${ENSEMBL_BASE_URL}/release-${ENSEMBL_RELEASE}/mysql/homo_sapiens_*_${ENSEMBL_RELEASE}_*
	/bin/mv -f $@.err $@

#logs/ensembl-%.log: FORCE
#	${WGET} \
#		${ENSEMBL_BASE_URL}/current_fasta/$*/pep \
#		${ENSEMBL_BASE_URL}/current_genbank/$*
#	/bin/mv -f $@.err $@


############################################################################
### GENE ONTOLOGY
UPDATE_TARGETS+=go
logs/go.log: FORCE
	${WGET} \
		ftp://ftp.geneontology.org/pub/go/doc/ \
		ftp://ftp.geneontology.org/pub/go/external2go/ \
		ftp://ftp.geneontology.org/pub/go/ontology/ \
		ftp://ftp.geneontology.org/pub/go/xml/ \
		ftp://ftp.geneontology.org/pub/godatabase/archive/full/2007*
	/bin/mv -f $@.err $@



############################################################################
### GENOME REFERENCE CONSORTIUM
UPDATE_TARGETS+=grch-${GRCH_VERSION}
.PHONY: grch
grch: grch-${GRCH_VERSION}
logs/grch-%.log: FORCE
	${WGET} ftp://ftp.ncbi.nih.gov/genbank/genomes/Eukaryotes/vertebrates_mammals/Homo_sapiens/GRCh$*/Primary_Assembly/assembled_chromosomes/FASTA/
	/bin/mv -f $@.err $@


############################################################################
### HOMOLOGENE (NCBI)
UPDATE_TARGETS+=homologene
logs/homologene.log: FORCE
	${WGET} ftp://ftp.ncbi.nih.gov/pub/HomoloGene/build${HOMOLOGENE_VERSION}/
	/bin/mv -f $@.err $@


############################################################################
### HUGE
UPDATE_TARGETS+=huge
logs/huge.log: FORCE
	${WGET} ftp://ftp.kazusa.or.jp/pub/huge/peplib.kiaa2038.tfa
	/bin/mv -f $@.err $@


############################################################################
### InterPro & iprscan
## logs/interpro.log: FORCE
UPDATE_TARGETS+=interpro
logs/interpro.log: FORCE
	${WGET} -R old_releases,database/mysql,potm,user_data ftp://ftp.ebi.ac.uk/pub/databases/interpro/
	/bin/mv -f $@.err $@
UPDATE_TARGETS+=iprscan
logs/iprscan.log: FORCE
	${WGET} ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/
	/bin/mv -f $@.err $@


############################################################################
### IPI
UPDATE_TARGETS+=ipi
logs/ipi.log: FORCE
	${WGET} -Adat.gz --retr-symlinks ftp://ftp.ebi.ac.uk/pub/databases/IPI/current/
	/bin/mv -f $@.err $@


############################################################################
### IMGT
UPDATE_TARGETS+=imgt
logs/imgt.log: FORCE
	${WGET} ftp://ftp.ebi.ac.uk/pub/databases/imgt
	/bin/mv -f $@.err $@


############################################################################
### MGC
UPDATE_TARGETS+=mgc
logs/mgc.log: FORCE
	${WGET} ftp://ftp1.nci.nih.gov/pub/MGC/fasta/
	/bin/mv -f $@.err $@


############################################################################
### MINT (Molecular INTeractions)
UPDATE_TARGETS+=mint
logs/mint.log: FORCE
	${WGET} ftp://mint.bio.uniroma2.it/pub/release/psi/${MINT_VERSION}/psi25
	/bin/mv -f $@.err $@


############################################################################
### NCBI ENTREZ GENE
UPDATE_TARGETS+=ncbi-gene
logs/ncbi-gene.log: FORCE
	${WGET} -l1 ftp://ftp.ncbi.nih.gov/gene/{GeneRIF,DATA}/ ftp://ftp.ncbi.nih.gov/gene/DATA/{gene2unigene,mim2gene}
	/bin/mv -f $@.err $@


############################################################################
### NCBI HUMAN GENOME
UPDATE_TARGETS+=ncbi-genomes
logs/ncbi-genomes.log: $(foreach s,${NCBI_SPECIES},logs/ncbi-genomes-${s}.log)
	/bin/ls -1 $^ >$@.err
	/bin/mv -f $@.err $@
logs/ncbi-genomes-H_sapiens.log: logs/ncbi-genomes-%.log:
	${WGET} ftp://ftp.ncbi.nih.gov/genomes/$*/{CHR*,Assembled_chromosomes/gbs/hs_ref*.gbs.gz}
	/bin/mv -f $@.err $@
logs/ncbi-genomes-%.log:
	@mkdir -p ${@D}
	${WGET} -Afaa ftp://ftp.ncbi.nih.gov/genomes/$*
	/bin/mv -f $@.err $@


############################################################################
### NCBI REFSEQ
UPDATE_TARGETS+=ncbi-refseq
logs/ncbi-refseq.log: FORCE
	${WGET} ftp://ftp.ncbi.nih.gov/refseq/release/release-notes
	${WGET} -Aprotein.faa.gz -Aprotein.gpff.gz ftp://ftp.ncbi.nih.gov/refseq/release/complete/
	/bin/mv -f $@.err $@


############################################################################
### NCBI TAXONOMY
UPDATE_TARGETS+=ncbi-tax
logs/ncbi-tax.log: FORCE
	${WGET} ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
	/bin/mv -f $@.err $@


############################################################################
### OMIM (NCBI)
UPDATE_TARGETS+=omim
logs/omim.log: FORCE
	${WGET} ftp://ftp.ncbi.nih.gov/repository/OMIM
	/bin/mv -f $@.err $@


############################################################################
### PhosphoELM
UPDATE_TARGETS+=phosphoelm
logs/phosphoelm.log: FORCE
	${WGET} http://phospho.elm.eu.org/phosphoELM_1208.tar.gz
	/bin/mv -f $@.err $@


############################################################################
### PROSITE
UPDATE_TARGETS+=prosite
logs/prosite.log: FORCE
	${WGET} ftp://ftp.expasy.org/databases/prosite/release_with_updates/
	/bin/mv -f $@.err $@


############################################################################
### PFAM
UPDATE_TARGETS+=pfam-${PFAM_VERSION}
.PHONY: pfam
pfam: pfam-${PFAM_VERSION}
logs/pfam-%.log: FORCE
	${WGET} ftp://ftp.sanger.ac.uk/pub/databases/Pfam/releases/Pfam$*
	/bin/mv -f $@.err $@


############################################################################
### REACTOME
UPDATE_TARGETS+=reactome
.PHONY: reactome
logs/reactome.log: FORCE
	${WGET} http://reactome.org/download/current/uniprot_2_pathways.stid.txt
	/bin/mv -f $@.err $@


############################################################################
### WWPDB
UPDATE_TARGETS+=wwpdb
.PRECIOUS: logs/wwpdb.log
logs/wwpdb.log: FORCE
	rsync -aRv --delete-after --port=33444 \
		rsync.wwpdb.org::ftp/data/structures/divided/XML/ \
		rsync.wwpdb.org::ftp/data/structures/divided/pdb/ \
		rsync.wwpdb.org::ftp/data/structures/all/pdb/ \
		rsync.wwpdb.org/ \
		>$@.err 2>&1
	/bin/mv -f $@.err $@


############################################################################
### ROUGE
UPDATE_TARGETS+=rouge
logs/rouge.log: FORCE
	${WGET} ftp://ftp.kazusa.or.jp/pub/rouge/peplib_060330
	/bin/mv -f $@.err $@


############################################################################
### SCOP
UPDATE_TARGETS+=scop
logs/scop.log: FORCE
	${WGET} http://scop.mrc-lmb.cam.ac.uk/scop/parse/dir.{cla,com,des,hie}.scop.txt_${SCOP_VERSION}
	/bin/mv -f $@.err $@


############################################################################
### STRING
UPDATE_TARGETS+=string
logs/string.log: FORCE
	${WGET}	http://string.embl.de/newstring_download/protein.sequences.v${STRING_VERSION}.fa.gz
	/bin/mv -f $@.err $@


############################################################################
### TIGRFAM
UPDATE_TARGETS+=tigrfam
OLD_RELEASES:=$(addsuffix _Release,1.0 1.1 1.2 2.0 2.1 3.0 4.0 4.1 5.0 6.0 7.0 8.0)
logs/tigrfam.log: FORCE
	${WGET} $(addprefix -X ,${OLD_RELEASES}) ftp://ftp.jcvi.org/pub/data/TIGRFAMs
	/bin/mv -f $@.err $@


############################################################################
### UC SANTA CRUZ ASSEMBLY
UPDATE_TARGETS+=hg19
logs/hg%.log:
	@mkdir -p ./hgdownload.cse.ucsc.edu/goldenPath
	rsync -HPRavz rsync://hgdownload.cse.ucsc.edu/goldenPath/hg$*/chromosomes ./hgdownload.cse.ucsc.edu/goldenPath/ >$@.err 2>&1
	/bin/mv -f $@.err $@


############################################################################
### UNIGENE
UPDATE_TARGETS+=unigene
logs/unigene.log: $(foreach s,${UNIGENE_SPECIES},logs/unigene-${s}.log)
	/bin/ls -1 $^ >$@.err
	/bin/mv -f $@.err $@
logs/unigene-%.log: FORCE
	${WGET} -Agz ftp://ftp.ncbi.nih.gov/repository/UniGene/$*
	/bin/mv -f $@.err $@


############################################################################
### UNIPROT et al
UPDATE_TARGETS+=uniprot uniref
logs/uniprot.log: FORCE
	${WGET} ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete
	/bin/mv -f $@.err $@
logs/uniref.log: FORCE
	${WGET} ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/uniref
	/bin/mv -f $@.err $@


############################################################################
### PIR
UPDATE_TARGETS+=pirsf iproclass
logs/pirsf.log: FORCE
	${WGET} ftp://ftp.pir.georgetown.edu/databases/pirsf/pirsfinfo.dat
	/bin/mv -f $@.err $@

logs/iproclass.log: FORCE
	${WGET} ftp://ftp.pir.georgetown.edu/databases/iproclass/iproclass.tb.gz
	/bin/mv -f $@.err $@

logs/pir.log: logs/pirsf.log logs/iproclass.log


############################################################################
### Personal Genomes Project
UPDATE_TARGETS+=pgp
logs/pgp.log: FORCE
	${WGET} http://www.personalgenomes.org/data/PGP9.3
	/bin/mv -f $@.err $@


############################################################################
### ICD
UPDATE_TARGETS+=icd10
logs/icd10.log: FORCE
	${WGET} http://www.cms.hhs.gov/ICD10/downloads/{Dxgem_2009.zip,Pcs2009_tabidx.zip}
	/bin/mv -f $@.err $@



logs/pubs-wang-nature-2008.log: logs/pubs-%.log:
	${WGET} -P pubs/$* \
		ftp://yhdata:yhdownload@yh.genomics.org.cn/Rawdata \
		ftp://yhdata:yhdownload@yh.genomics.org.cn/Rawdata2 \
		ftp://yhdata:yhdownload@yh.genomics.org.cn/soap \
		ftp://yhdata:yhdownload@yh.genomics.org.cn/geno_soap3 \
		ftp://yhdata:yhdownload@yh.genomics.org.cn/haplotype
	/bin/mv -f $@.err $@


logs/pubs-ng-12-exomes-nature-2009.log: logs/pubs-%.log:
	${WGET} -P pubs/$* \
		ftp://ftp.ncbi.nih.gov/sra/Studies/SRP000/SRP000910/
	/bin/mv -f $@.err $@


############################################################################
### External makefiles, which may not exist
### Proprietary stuff goes in subordinate files
-include Makefile-genentech


############################################################################
### shorthands (e.g., rcsb : logs/rcsb.log)
.PHONY: ${UPDATE_TARGETS}
${UPDATE_TARGETS} : % : logs/%.log;

.PHONY: update
update: ${UPDATE_TARGETS}



dusk:
	du -sk * | sort -rn >$@.err
	/bin/mv -f $@.err $@


.PHONY: clean cleaner cleanest
clean:
	/bin/rm -f *~ *.bak
cleaner: clean
	/bin/rm -f logs/*.log logs/*.err
cleanest: cleaner
	# cleanest: removal of everything else is left to you

