include ../common.mk
include ../local.mk
include ../params.mk

TEMPLATE_ROOT:=${RESEARCH_PREFIX}/apps/prospect/current/data
fssp_ROOT:=${TEMPLATE_ROOT}/templates_xml
scop_ROOT:=${TEMPLATE_ROOT}/templates_scop
PMPROSPECT_DATA_DIR:=${UNISON_HOME}/runtime/data/pmprospect

ORIGIN:=Prospect-3.0/FSSP

%.ids: %.list 
	perl -e 'my $$root=shift;opendir(D,$$root);my @f= grep {/.xml/} sort readdir(D);print "$$root/$$_\n",foreach @f;' $* > $@.tmp
	mv $@.tmp $@

%.list: 
	perl -e 'my $$root=shift;opendir(D,$$root);my @f= grep {/.xml/} sort readdir(D);foreach (@f){s/\.xml//;print "$$_\n";}' ${$*_ROOT} > $@.tmp
	mv $@.tmp ${PMPROSPECT_DATA_DIR}/$@

%.load: %.ids
	(time -p cat $< | load-pmprospect -o ${ORIGIN} -v)>$@.err 2>&1
	/bin/mv -f $@.err $@

.done.ids:
	psql -Atc "select acc from pmprospect where origin_id=origin_id('${ORIGIN}')" >$@
