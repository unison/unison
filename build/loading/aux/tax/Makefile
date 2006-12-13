include ../../local.mk
include ../../common.mk
include ../../params.mk

update default all: load-speclist.log; 

load-speclist.log: ${RESEARCH_PREFIX}/data/public/uniprot/docs/speclist.txt
	time -p ./bin/spspec2sql $< | ${PSQL} -f -

# ncbi/taxdump.tar.gz:
# 	@mkdir -p ${@D}
# 	wget -P${@D} -nd ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
# ncbi/readme.txt: ncbi/taxdump.tar.gz
# 	cd ${@D}; tar -xvzf ${<F}
