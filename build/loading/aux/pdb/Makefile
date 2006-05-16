include ../../common.mk
include ../../local.mk


PDB_ROOT:=${COMPBIO_PREFIX}/share/pdb
export PDB_XML_PATH:=${PDB_ROOT}/all.xml.gz


update default all: allxml-todo.load


%.load: %.ids
	(time -p ./load-pdblite < $<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

allxml.ids: exclude.ids FORCE
	find ${PDB_XML_PATH}/ -name \*.gz | perl -lne 'print $$1 if m%/(\w{4})\.xml\.gz%' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	comm -23 $@.tmp $< >$@.tmp2
	/bin/mv -f $@.tmp2 $@
	/bin/rm $@.tmp
	@wc -l $@

done.ids:
	psql -Atc 'select pdbid from pdb.summary' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@
