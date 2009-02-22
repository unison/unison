.SUFFIXES:
.DELETE_ON_ERROR:
.PHONY: FORCE

export PATH=/gne/research/apps/postgresql/prd/x86_64-linux-2.6/bin:/usr/bin:/bin
export PGHOST:=respgsql
export PGDATABASE:=logs

INSTANCE:=respub


SHELL:=/bin/bash


%-build: src/apache-rebuild.sql.m4
	m4 -D__SCHEMA=$* $< | psql -Xa



load-%:
	find logs/$*/ -name access_log\*.gz | perl -pe 's/^logs/loadlog/; s/\.gz$$/.log/' | tr \\012 \\0 | xargs -0r make

load/${INSTANCE}/apache/%.log: logs/${INSTANCE}/apache/%.gz
	mkdir -p ${@D}
	@S=`expr "$@" : 'load/\([^/]*\)'`; set -o pipefail; \
	echo "# loading $< into $$S" 1>&2; \
	gzip -cd <$< | ./bin/accesslog2csv \
	| psql -h respgsql -d logs -c "set search_path = $$S; COPY apache_log FROM STDIN WITH csv NULL as 'NULL'" >$@.err 2>&1
	/bin/mv -f "$@.err" "$@"

# depends on PGHOST=respgsql PGDATABASE=logs
%-update
	./bin/update-src_host_ip $*




# NOTE: Beware of loading 
#load-%:
#	find logs/$*/ -name \*.csv | perl -pe 's/^logs/loadlog/; s/\.csv$$/.log/' | tr \\012 \\0 | xargs -0r make
#
#load/${INSTANCE}/postgresql/%.log: logs/${INSTANCE}/postgresql/%.csv.gz
#	mkdir -p ${@D}
#	S=`expr "$@" : 'loadlog/\([^/]*\)'`; \
#	psql -h respgsql -d logs -c "set search_path = $$S; COPY postgres_log FROM STDIN WITH csv" <$< >$@.err 2>&1
#	/bin/mv -f "$@.err" "$@"




.PHONY: get-logs get-logs-respub
get-logs: get-logs-respub
get-logs-respub:
	rsync --delete -PHav respub:logs/postgresql/ 		logs/respub/postgresql/
	rsync --delete -PHav respub:/data/www/logs/unison/	logs/respub/apache/



.PHONY: clean cleaner cleanest
clean:
	/bin/rm -f *~
cleaner: clean
	find logs/*/apache/ \( -name access_log\*.csv\* \) -print0 | xargs -0r rm -fv
cleanest: cleaner
	find load/*/ \( -name \*.log -o -name \*.err \) -print0 | xargs -0r rm -fv
