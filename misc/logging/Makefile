.SUFFIXES:
.DELETE_ON_ERROR:
.PHONY: FORCE

export PGHOST:=respgsql
export PGDATABASE:=logs

export PATH=/gne/research/apps/postgresql/prd/x86_64-linux-2.6/bin:/usr/bin:/bin

INSTANCE:=respub


%-build: rebuild.sql.m4
	psql -c


load-%:
	find logs/$*/ -name access_log\*.gz | perl -pe 's/^logs/loadlog/; s/\.gz$$/.log/' | tr \\012 \\0 | xargs -0r make

logs/${INSTANCE}/apache/%.csv.gz: logs/${INSTANCE}/apache/%.gz
	gzip -cd <$< | ./bin/accesslog2csv | gzip -c >$@

load/${INSTANCE}/apache/%.log: logs/${INSTANCE}/apache/%.csv.gz
	mkdir -p ${@D}
	S=`expr "$@" : 'load/\([^/]*\)'`; \
	gzip -cd <$< \
	| psql -h respgsql -d logs -c "set search_path = $$S; COPY apache_log FROM STDIN WITH csv" <$< >$@.err 2>&1
	/bin/mv -f "$@.err" "$@"


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
	find logs/*/ \( -name \*.csv* \) -print0 | xargs rm -fv
cleanest: cleaner
	find loadlog/*/ \( -name \*.log -o -name \*.err \) -print0 | xargs rm -fv
