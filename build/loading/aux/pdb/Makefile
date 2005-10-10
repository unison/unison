include ../../loading/common.mk

PDB_ROOT:=/gne/compbio/share/pdb/
export PDBXML_PATH:=${PDB_ROOT}all.xml.gz
PDB_INHOUSE:=${PDB_ROOT}all.pdb

default:
	@echo no $@ target; exit 1

%.load: %.ids
	(time -p ./load-pdblite < $<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

pdbext.ids:
	for i in `ls ${PDBXML_PATH}`; do echo $${i:0:4}; done > $@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv $@.tmp $@
	@wc -l $@

inhouse.ids:
	for i in `ls ${PDB_INHOUSE}`; do echo $$i; done > $@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv $@.tmp $@
	@wc -l $@

done.ids:
	psql -Atc 'select pdbid from pdb.summary' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@
