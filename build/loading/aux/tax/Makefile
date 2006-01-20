include ../../common.mk


update default all: load-speclist.log; 

load-speclist.log: ${COMPBIO_PREFIX}/share/uniprot/docs/speclist.txt
	./bin/load-speclist $<


# ncbi/taxdump.tar.gz:
# 	@mkdir -p ${@D}
# 	wget -P${@D} -nd ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
# ncbi/readme.txt: ncbi/taxdump.tar.gz
# 	cd ${@D}; tar -xvzf ${<F}
