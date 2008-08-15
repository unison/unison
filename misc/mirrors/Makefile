.SUFFIXES:
.PHONY: FORCE

############################################################################
# TODO
## * automatically determine download version for pfam, homologene,
## ensembl, and scop

############################################################################
### CONFIGURATION
PFAM_VERSION:=22.0
HOMOLOGENE_VERSION:=56
SCOP_VERSION:=1.73
ENSEMBL_VERSION:=48
ENSEMBL_BASE_URL:=ftp://ftp.ensembl.org/pub
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
STRING_VERSION:=7.1


WGET=wget -o$@.err -m -np
# -o log
# -m mirror
# -nv not verbose (er, semi quiet)
# -np no parents (don't ascend)
# other options: --limit-rate=1m --waitretry=1


default: update


############################################################################
### ASTRAL
### http://astral.berkeley.edu/
CURRENCY_TARGETS+=astral
logs/astral.log: FORCE
	${WGET} http://astral.berkeley.edu/scopseq-${SCOP_VERSION}


############################################################################
### BLAST STUFF (NBCI)
CURRENCY_TARGETS+=nr pataa blast-matrices blast
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
### CCDS
CURRENCY_TARGETS+=ccds
logs/ccds.log:
	${WGET} -R archive ftp://ftp.ncbi.nih.gov/pub/CCDS
	/bin/mv -f $@.err $@


############################################################################
### CDD
CURRENCY_TARGETS+=cdd
logs/cdd.log: FORCE
	${WGET} ftp://ftp.ncbi.nih.gov/pub/mmdb/cdd/
	/bin/mv -f $@.err $@


############################################################################
### CHEBI
CURRENCY_TARGETS+=chebi
logs/chebi.log: FORCE
	${WGET} ftp://ftp.ebi.ac.uk/pub/databases/chebi/README.txt \
			ftp://ftp.ebi.ac.uk/pub/databases/chebi/generic_dumps \
			ftp://ftp.ebi.ac.uk/pub/databases/chebi/ontology \
			ftp://ftp.ebi.ac.uk/pub/databases/chebi/schema.gif \
			ftp://ftp.ebi.ac.uk/pub/databases/chebi/tutorial
	/bin/mv -f $@.err $@


############################################################################
### COSMIC
CURRENCY_TARGETS+=cosmic
logs/cosmic.log: FORCE
	${WGET} ftp://ftp.sanger.ac.uk/pub/CGP/cosmic/fasta_files/*_protein.txt -O - >> cosmic.fa
	/bin/mv -f cosmic.fa ftp.sanger.ac.uk/pub/CGP/cosmic/fasta_files
	/bin/mv -f $@.err $@


############################################################################
### DALI
CURRENCY_TARGETS+=dali
logs/dali.log:
	# DALI
	# older version (prod?)
	# ${WGET} http://www.bioinfo.biocenter.helsinki.fi:8080/dali/download.html http://www.bioinfo.biocenter.helsinki.fi:8080/dali/dali_dccp.gz http://www.bioinfo.biocenter.helsinki.fi:8080/dali/dali_fragments.gz http://www.bioinfo.biocenter.helsinki.fi:8080/dali/TABLE2
	# newer version (dev?)
	# ${WGET} http://ekhidna.biocenter.helsinki.fi:8080/dali/download.html http://ekhidna.biocenter.helsinki.fi:8080/dali/dali_dccp.gz http://ekhidna.biocenter.helsinki.fi:8080/dali/dali_fragments.gz http://ekhidna.biocenter.helsinki.fi:8080/dali/TABLE2
	# even more newer version (?)
	${WGET} http://ekhidna.biocenter.helsinki.fi/dali/downloads/download.html http://ekhidna.biocenter.helsinki.fi/dali/downloads/dali_dccp.gz http://ekhidna.biocenter.helsinki.fi:/dali/downloads/dali_fragments.gz http://ekhidna.biocenter.helsinki.fi/dali/downloads/TABLE2
	/bin/mv -f $@.err $@


############################################################################
### ENSEMBL
CURRENCY_TARGETS+=ensembl
logs/ensembl.log: $(foreach s,${ENSEMBL_SPECIES},logs/ensembl-${ENSEMBL_VERSION}-${s}.log)
	/bin/ls -1 $^ >$@.err
	/bin/mv -f $@.err $@
logs/ensembl-${ENSEMBL_VERSION}-%.log: FORCE
	${WGET} \
		${ENSEMBL_BASE_URL}/release-${ENSEMBL_VERSION}/fasta/$*/pep \
		${ENSEMBL_BASE_URL}/release-${ENSEMBL_VERSION}/genbank/$*
	/bin/mv -f $@.err $@


############################################################################
### GENE ONTOLOGY
CURRENCY_TARGETS+=go
logs/go.log: FORCE
	${WGET} \
		ftp://ftp.geneontology.org/pub/go/doc/ \
		ftp://ftp.geneontology.org/pub/go/external2go/ \
		ftp://ftp.geneontology.org/pub/go/ontology/ \
		ftp://ftp.geneontology.org/pub/go/xml/ \
		ftp://ftp.geneontology.org/pub/godatabase/archive/full/2007*
	/bin/mv -f $@.err $@


############################################################################
### HOMOLOGENE (NCBI)
CURRENCY_TARGETS+=homologene
logs/homologene.log: FORCE
	${WGET} ftp://ftp.ncbi.nih.gov/pub/HomoloGene/build${HOMOLOGENE_VERSION}/
	/bin/mv -f $@.err $@


############################################################################
### HUGE
CURRENCY_TARGETS+=huge
logs/huge.log: FORCE
	${WGET} ftp://ftp.kazusa.or.jp/pub/huge/peplib.kiaa2038.tfa
	/bin/mv -f $@.err $@


############################################################################
### InterPro & iprscan
## logs/interpro.log: FORCE
CURRENCY_TARGETS+=interpro
logs/interpro.log: FORCE
	${WGET} -R old_releases,database/mysql,potm,user_data ftp://ftp.ebi.ac.uk/pub/databases/interpro/
	/bin/mv -f $@.err $@
CURRENCY_TARGETS+=iprscan
logs/iprscan.log: FORCE
	${WGET} ftp://ftp.ebi.ac.uk/pub/software/unix/iprscan/
	/bin/mv -f $@.err $@


############################################################################
### IPI
CURRENCY_TARGETS+=ipi
logs/ipi.log: FORCE
	${WGET} -Adat.gz --retr-symlinks ftp://ftp.ebi.ac.uk/pub/databases/IPI/current/
	/bin/mv -f $@.err $@


############################################################################
### IMGT
CURRENCY_TARGETS+=imgt
logs/imgt.log: FORCE
	${WGET} ftp://ftp.ebi.ac.uk/pub/databases/imgt
	/bin/mv -f $@.err $@


############################################################################
### MGC
CURRENCY_TARGETS+=mgc
logs/mgc.log: FORCE
	${WGET} ftp://ftp1.nci.nih.gov/pub/MGC/fasta/
	/bin/mv -f $@.err $@


############################################################################
### NCBI ENTREZ GENE
CURRENCY_TARGETS+=ncbi-gene
logs/ncbi-gene.log: FORCE
	${WGET} -l1 ftp://ftp.ncbi.nih.gov/gene/{GeneRIF,DATA}/ ftp://ftp.ncbi.nih.gov/gene/DATA/{gene2unigene,mim2gene}
	/bin/mv -f $@.err $@

############################################################################
### NCBI HUMAN GENOME
CURRENCY_TARGETS+=ncbi-genomes
logs/ncbi-genomes.log: $(foreach s,${NCBI_SPECIES},logs/ncbi-genomes-${s}.log)
	/bin/ls -1 $^ >$@.err
	/bin/mv -f $@.err $@
logs/ncbi-genomes-H_sapiens.log: logs/ncbi-genomes-%.log:
	${WGET} ftp://ftp.ncbi.nih.gov/genomes/$*/CHR*
	/bin/mv -f $@.err $@
logs/ncbi-genomes-%.log:
	@mkdir -p ${@D}
	${WGET} -Afaa ftp://ftp.ncbi.nih.gov/genomes/$*
	/bin/mv -f $@.err $@

############################################################################
### NCBI REFSEQ
CURRENCY_TARGETS+=ncbi-refseq
logs/ncbi-refseq.log: FORCE
	${WGET} ftp://ftp.ncbi.nih.gov/refseq/release/release-notes
	${WGET} -Aprotein.faa.gz -Aprotein.gpff.gz ftp://ftp.ncbi.nih.gov/refseq/release/complete/
	/bin/mv -f $@.err $@

############################################################################
### NCBI TAXONOMY
CURRENCY_TARGETS+=ncbi-tax
logs/ncbi-tax.log: FORCE
	${WGET} ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
	/bin/mv -f $@.err $@

############################################################################
### OMIM (NCBI)
CURRENCY_TARGETS+=omim
logs/omim.log: FORCE
	${WGET} ftp://ftp.ncbi.nih.gov/repository/OMIM
	/bin/mv -f $@.err $@


############################################################################
### PROSITE
CURRENCY_TARGETS+=prosite
logs/prosite.log: FORCE
	${WGET} ftp://ftp.expasy.org/databases/prosite/release_with_updates/
	/bin/mv -f $@.err $@


############################################################################
### PFAM
CURRENCY_TARGETS+=pfam-${PFAM_VERSION}
.PHONY: pfam
pfam: pfam-${PFAM_VERSION}
logs/pfam-%.log: FORCE
	${WGET} ftp://selab.janelia.org/pub/pfam/pfam-$*
	/bin/mv -f $@.err $@


############################################################################
### REACTOME
CURRENCY_TARGETS+=reactome
.PHONY: reactome
logs/reactome.log: FORCE
	${WGET} http://reactome.org/download/current/uniprot_2_pathways.stid.txt
	/bin/mv -f $@.err $@


############################################################################
### WWPDB
# WARNING: --retr-symlinks doesn't set timestamps correctly
CURRENCY_TARGETS+=wwpdb
PDB_URL:=ftp://ftp.wwpdb.org
.PRECIOUS: logs/wwpdb.log
logs/wwpdb.log: FORCE
	umask 022; \
	${WGET} \
		${PDB_URL}/pub/pdb/data/structures/divided/XML/ \
		${PDB_URL}/pub/pdb/data/structures/divided/pdb/ \
		${PDB_URL}/pub/pdb/derived_data \
		http://remediation.wwpdb.org/downloads/Components-rel-alt.xml.gz
	/bin/mv -f $@.err $@
	#
	find /gne/research/data/public/pdb /gne/research/data/mirrors/ftp.wwpdb.org \
		\( -type f \! -perm -444 \) -o \( -type d \! -perm -111 \) \
	| xargs /bin/ls -ld >/tmp/pdb-perm-faults.ls
	wc -l /tmp/pdb-perm-faults.ls >>$@


############################################################################
### ROUGE
CURRENCY_TARGETS+=rouge
logs/rouge.log: FORCE
	${WGET} ftp://ftp.kazusa.or.jp/pub/rouge/peplib_060330
	/bin/mv -f $@.err $@


############################################################################
### SCOP
CURRENCY_TARGETS+=scop
logs/scop.log: FORCE
	${WGET} http://scop.mrc-lmb.cam.ac.uk/scop/parse/dir.{cla,com,des,hie}.scop.txt_${SCOP_VERSION}
	/bin/mv -f $@.err $@


############################################################################
### STRING
CURRENCY_TARGETS+=string
logs/string.log: FORCE
	${WGET}	http://string.embl.de/newstring_download/protein.sequences.v${STRING_VERSION}.fa.gz
	/bin/mv -f $@.err $@


############################################################################
### UC SANTA CRUZ ASSEMBLY
# CURRENCY_TARGETS+=ucsc
logs/hg18.log:
	( \
	set -e; \
	wget -q -O- http://hgdownload.cse.ucsc.edu/goldenPath/hg18/chromosomes/ \
	| perl -ln0e 'while (m/chr.+?fa.gz/g) { print "http://hgdownload.cse.ucsc.edu/goldenPath/hg18/chromosomes/$$&" }' \
	| ${WGET} -i-; \
	) >$@.err 2>&1
	/bin/mv -f $@.err $@


############################################################################
### UNIGENE
CURRENCY_TARGETS+=unigene
logs/unigene.log: $(foreach s,${UNIGENE_SPECIES},logs/unigene-${s}.log)
	/bin/ls -1 $^ >$@.err
	/bin/mv -f $@.err $@
logs/unigene-%.log: FORCE
	${WGET} -Agz ftp://ftp.ncbi.nih.gov/repository/UniGene/$*
	/bin/mv -f $@.err $@


############################################################################
### UNIPROT
CURRENCY_TARGETS+=uniprot
logs/uniprot.log: FORCE
	${WGET} ftp://ftp.uniprot.org/pub/databases/uniprot/current_release/knowledgebase/complete
	/bin/mv -f $@.err $@






############################################################################
#########################	 PROPRIETARY STUFF   ###########################
############################################################################

############################################################################
### DERWENT
CURRENCY_TARGETS+=geneseq
logs/geneseq.log: FORCE
	${WGET} --user=genentech --password=genentech ftp://ftp.derwent.co.uk/
	/bin/mv -f $@.err $@

############################################################################
### Francisella tularensis genome
ftu.log: FORCE
	${WGET} --http-user=dixit --http-passwd=fold \
		http://artedi.ebc.uu.se/Projects/Francisella/rightpage_tul1.html \
		http://artedi.ebc.uu.se/Projects/Francisella/data/FAQ.html \
		http://artedi.ebc.uu.se/Projects/Francisella/data/Francisella_2002-09-12
	/bin/mv -f $@.err $@




.PHONY: update
update: ${CURRENCY_TARGETS}

############################################################################
### shorthands (e.g., rcsb : logs/rcsb.log)
.PHONY: ${CURRENCY_TARGETS}
${CURRENCY_TARGETS} : % : logs/%.log;


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

