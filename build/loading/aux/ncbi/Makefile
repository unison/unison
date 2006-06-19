default all: update


include ../../common.mk
include ../../local.mk
include ../../params.mk


TABLES_UC_SRCS:=gene2unigene mim2gene
TABLES_GZ_SRCS:=gene2accession gene2go gene_info
TABLES_OTHER:=homologene generif
TABLES:=${TABLES_UC_SRCS} ${TABLES_GZ_SRCS} ${TABLES_OTHER} 

_D:=$(shell mkdir -p logs)


update: $(foreach t,${TABLES},logs/$t-load.log)

# There are two types of operations: table create and table load.  Each
# has a log file.


# "create" logs
$(foreach t,${TABLES},logs/$t-create.log): logs/%.log: sql/%.sql
	${PSQL} -f $< 2>&1 | tee $@


# "load" logs
logs/homologene-load.log: ${HOMOLOGENE_DATA}
	(time -p ${PSQL} -f sql/homologene-load.sql <$<) >$@.err 2>&1
	/bin/mv -f $@.err $@

$(foreach t,${TABLES_GZ_SRCS},logs/$t-load.log): logs/%-load.log: ${GENE_DIR}/DATA/%.gz logs/%-create.log
	(gzip -cdq <$< | perl -ne 'print unless m/^#/' | ${PSQL} -f sql/$*-load.sql) | tee $@.err
	/bin/mv -f $@.err $@

$(foreach t,${TABLES_UC_SRCS},logs/$t-load.log): logs/%-load.log: ${GENE_DIR}/DATA/% logs/%-create.log
	perl -ne 'print unless m/^#/' <$< | ${PSQL} -f sql/$*-load.sql | tee $@.err
	/bin/mv -f $@.err $@

logs/generif-load.log: logs/%-load.log: ${GENE_DIR}/GeneRIF/generifs_basic.gz logs/%-create.log
	(gzip -cdq <$< | perl -ne 'print unless m/^#/' | ${PSQL} -f sql/$*-load.sql) | tee $@.err
	/bin/mv -f $@.err $@
