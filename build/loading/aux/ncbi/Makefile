HOMOLOGENE_URL:=ftp://ftp.ncbi.nih.gov/pub/HomoloGene/build44.1/homologene.data

homologene.load:
	wget -nv -nd -O- ${HOMOLOGENE_URL} | psql -Xf sql/homologene-load.sql
