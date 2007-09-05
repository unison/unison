include ../common.mk
include ../local.mk
include ../params.mk

default: cleanest Prosite.load

PROSITE_VERSION:=`${PSQL_DCMD} "select data_url from origin where origin_id=origin_id('Prosite')" | sed -e "s/prosite.dat/ps_reldt.txt/" | xargs cat | cut -d  ' ' -f 3`

Prosite.load:
	load-pmprosite -v --version ${PROSITE_VERSION} --deprecate >$@.err 2>&1
	/bin/mv -f $@.err $@
