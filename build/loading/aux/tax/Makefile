

ncbi/taxdump.tar.gz:
	@mkdir -p ${@D}
	wget -P${@D} -nd ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz
ncbi/readme.txt: ncbi/taxdump.tar.gz
	cd ${@D}; tar -xvzf ${<F}

speclist.txt:
	wget -nd ftp://us.expasy.org/databases/swiss-prot/release/speclist.txt
