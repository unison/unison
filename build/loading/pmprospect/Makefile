include ../common.mk
include ../local.mk
include ../params.mk

TEMPLATE_ROOT:=${COMPBIO_PREFIX}/i686-linux-2.6/opt/prospect/data
FSSP_ROOT:=${TEMPLATE_ROOT}/templates_xml
SCOP_ROOT:=${TEMPLATE_ROOT}/templates_scop

ORIGIN:=Prospect-3.0/FSSP

fssp.ids:
	perl -e 'my $$root=shift;opendir(D,$$root);my @f= grep {/.xml/} sort readdir(D);print "$$root/$$_\n",foreach @f;' ${FSSP_ROOT} > $@.tmp
	mv $@.tmp $@

scop.ids:
	perl -e 'my $$root=shift;opendir(D,$$root);my @f= grep {/.xml/} sort readdir(D);print "$$root/$$_\n",foreach @f;' ${SCOP_ROOT} > $@.tmp
	mv $@.tmp $@

%.load: %.ids
	(time -p cat $< | load-pmprospect -o ${ORIGIN} -v)>$@.err 2>&1
	/bin/mv -f $@.err $@

.done.ids:
	psql -Atc "select acc from pmprospect where origin_id=origin_id('${ORIGIN}')" >$@
