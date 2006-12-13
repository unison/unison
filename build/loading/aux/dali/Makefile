# Makefile for loading dali into a postgresql database
# $Id: Makefile,v 1.2 2005/06/16 03:51:56 rkh Exp $


vpath % /gne/research/data/public/dali/

## load aln_ids <= 100 for testing:
#TEST:=| perl -pe 'exit(0) if $$F[0] > 100'

export PGHOST=csb
export PGUSER=unison
export PGDATABASE=csb-dev

default: dccp.log fragments.log
	@echo "dali has been loaded"

drop:
	-psql -c 'drop table dali.fragments; drop table dali.dccp'

schema.log: schema.sql
	psql -f $< | tee "$@.tmp"
	/bin/mv -f "$@.tmp" "$@"

dccp.log: dali_dccp.gz schema.log
	(gzip -cdq $< ${TEST} | ./dccp-to-copy | time -p psql -qaf- ) >"$@.tmp" 2>&1
	/bin/mv -f "$@.tmp" "$@"

fragments.log: dali_fragments.gz dccp.log
	(gzip -cdq $< ${TEST} | ./fragments-to-copy | time -p psql -qaf- ) >"$@.tmp" 2>&1
	/bin/mv -f "$@.tmp" "$@"



dccp: dali_dccp.gz
	gzip -cdq  | split -l10000 - $</
split-dccp.log: dccp
	for f in $</qr; do echo $$f; ./dccp-to-copy <$$f | time -p psql -qaf- >$$f.log 2>&1; done


.PHONY: clean cleaner cleanest
clean:
	/bin/rm -f *~ *.tmp
cleaner: clean
cleanest: cleaner drop
	/bin/rm -f rm *.log
