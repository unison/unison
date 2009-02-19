.SUFFIXES:
.PHONY: FORCE

############################################################################
# TODO
## * automatically determine download version for pfam, homologene,
## ensembl, and scop

############################################################################
### CONFIGURATION

# versions -- check these frequently and manually
HOMOLOGENE_VERSION:=63
MINT_VERSION:=2008-10-01
PFAM_VERSION:=23.0
SCOP_VERSION:=1.73
STRING_VERSION:=7.1

ASTRAL_VERSION:=${SCOP_VERSION}

# other config that doesn't change often
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
### DALI
UPDATE_TARGETS+=dali
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
UPDATE_TARGETS+=ensembl
logs/ensembl.log: $(foreach s,${ENSEMBL_SPECIES},logs/ensembl-${s}.log)
	/bin/ls -1 $^ >$@.err
	/bin/mv -f $@.err $@
logs/ensembl-%.log: FORCE
	${WGET} \
		${ENSEMBL_BASE_URL}/current_fasta/$*/pep \
		${ENSEMBL_BASE_URL}/current_genbank/$*
	/bin/mv -f $@.err $@


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
	${WGET} ftp://ftp.ncbi.nih.gov/genomes/$*/CHR*
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
	${WGET} ftp://selab.janelia.org/pub/pfam/pfam-$*
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
# WARNING: --retr-symlinks doesn't set timestamps correctly
UPDATE_TARGETS+=wwpdb
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
	chmod -cR a+rX ftp.wwpdb.org


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
OLD_RELEASES:=$(addsuffix _Release,1.0 1.1 1.2 2.0 2.1 3.0 4.0 4.1 5.0 6.0)
logs/tigrfam.log: FORCE
	${WGET} $(addprefix -X ,${OLD_RELEASES}) ftp://ftp.jcvi.org/pub/data/TIGRFAMs
	/bin/mv -f $@.err $@


############################################################################
### UC SANTA CRUZ ASSEMBLY
# UPDATE_TARGETS+=ucsc
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
#########################	 PROPRIETARY STUFF   ###########################
############################################################################

############################################################################
### DERWENT
UPDATE_TARGETS+=geneseq
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
update: ${UPDATE_TARGETS}

############################################################################
### shorthands (e.g., rcsb : logs/rcsb.log)
.PHONY: ${UPDATE_TARGETS}
${UPDATE_TARGETS} : % : logs/%.log;


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

