include ../../local.mk
include ../../common.mk
include ../../params.mk



PDB_ROOT:=/gne/research/data/public/pdb
export PDB_XML_PATH:=${PDB_ROOT}/all.xml.gz

LIGAND_DATA:=${PDB_ROOT}/components-pub-xml.tar.gz

update default all: ligands.load allxml-todo.load

ligands.load: ligands.sql
	(time -p ${PSQL} -qf $<) >$@.err 2>&1
	/bin/mv -f $@.err $@

ligands.sql: ${LIGAND_DATA}
	./load-ligands $< > $@.tmp 2>$@.err
	/bin/mv -f $@.tmp $@
	/bin/mv -f $@.err $@.log

%.load: %.ids
	(time -p ./load-pdblite --update < $<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

allxml.ids: exclude.list FORCE
	find ${PDB_XML_PATH}/ -name \*.gz | perl -lne 'print $$1 if m%/(\w{4})\.xml\.gz%' >$@.tmp
	sort -u -o $@.tmp $@.tmp
	comm -23 $@.tmp $< >$@.tmp2
	/bin/mv -f $@.tmp2 $@
	/bin/rm $@.tmp
	@wc -l $@

done.ids:
	find ${PDB_XML_PATH} -type f -name "*.xml.gz" -printf '%f\t%TD %TT\n' | ${PSQL} -Aqtf done.sql >$@.tmp
	/bin/mv -f $@.tmp $@
	@wc -l $@

%.load_atom: %.ids
	(time -p ./load-pdblite --atomic < $<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@

# %-load -- make the .load targets for a set of .id files, run locally
# %-qload -- same, but submit each job to qsub
# e.g., make pset42-todo-l500-qload
PATTERN=*
%-load_atom: %
	@for f in $*/${PATTERN}.ids; do echo "$${f%ids}load_atom"; done | tr \\012 \\0 | xargs -0rt ${MAKE} $J
%-qload_atom: %
	@for f in $*/${PATTERN}.ids; do echo "qsub/$${f%ids}load_atom"; done | tr \\012 \\0 | xargs -0rt ${MAKE} $J

