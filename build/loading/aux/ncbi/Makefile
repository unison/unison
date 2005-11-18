NCBI_BASE_URL:=ftp://ftp.ncbi.nih.gov/
GENE_DIR:=/gne/compbio/share/ncbi/gene
HOMOLOGENE_URL:=${NCBI_BASE_URL}/pub/HomoloGene/current/homologene.data

TABLES_UC_SRCS:=gene2unigene mim2gene
TABLES_GZ_SRCS:=gene2accession gene2go gene_info
TABLES_OTHER:=homologene generif
TABLES:=${TABLES_UC_SRCS} ${TABLES_GZ_SRCS} ${TABLES_OTHER} 

export PGUSER=unison


default all: $(foreach t,${TABLES},logs/$t-load.log)

$(foreach t,${TABLES},logs/$t-create.log): logs/%.log: sql/%.sql
	psql -Xf $< 2>&1 | tee $@

logs/homologene-load.log:
	(wget -nv -nd -O- ${HOMOLOGENE_URL} | psql -Xf sql/homologene-load.sql) | tee $@.err
	/bin/mv -f $@.err $@

$(foreach t,${TABLES_GZ_SRCS},logs/$t-load.log): logs/%-load.log: ${GENE_DIR}/DATA/%.gz logs/%-create.log
	(gzip -cdq <$< | perl -ne 'print unless m/^#/' | psql -Xf sql/$*-load.sql) | tee $@.err
	/bin/mv -f $@.err $@

$(foreach t,${TABLES_UC_SRCS},logs/$t-load.log): logs/%-load.log: ${GENE_DIR}/DATA/% logs/%-create.log
	perl -ne 'print unless m/^#/' <$< | psql -Xf sql/$*-load.sql | tee $@.err
	/bin/mv -f $@.err $@

logs/generif-load.log: logs/%-load.log: ${GENE_DIR}/GeneRIF/generifs_basic.gz logs/%-create.log
	(gzip -cdq <$< | perl -ne 'print unless m/^#/' | psql -Xf sql/$*-load.sql) | tee $@.err
	/bin/mv -f $@.err $@


#gene2accession.load gene_info.load: %.load:
#	wget -nv -nd -O- ${GENE_BASE_URL}/$*.gz | gzip -cd | psql -Xf sql/$*-load.sql
