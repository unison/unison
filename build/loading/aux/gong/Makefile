# -*-Makefile-*-

# Change these for your site:
MY2PG:=/apps/compbio/src/postgresql-7.3.2/contrib/mysql/my2pg.pl
export PGHOST=td-svc
export PGDATABASE=go
export PGUSER=admin



default all:
	@echo "There ain't no stinking default target, homey.  You may make:"; \
	echo "  godb.sql -- the postgresql sql create-and-load script"; \
	echo "  load-godb.log -- actually load the above"; \
	echo "  go.pgdump.gz -- get a pgdump of the go database"; \
	echo "  clean, cleaner, cleanest -- cleanup stuff"; \
	echo "I know it sounds strange, but consider reading the README file"; \
	exit 1



load-godb.log: godb.sql
	psql -qaf $< | tee $@.tmp
	/bin/mv $@.tmp $@

godb.sql: prep.sql schema.sql load.sql
	cat $^ >$@

schema.sql:: tables
schema.sql:: $(wildcard tables/*.sql)
	(cd tables; ${MY2PG} *.sql) >$@
tables:
	@echo "I don't see the tables/ directory.  You need to:"; \
	echo "  1) get go_<date>-termdb-tables.tar.gz from"; \
	echo "      http://www.godatabase.org/dev/database/archive/latest/"; \
	echo "  2) tar -xzf go_<date>-termdb-tables.tar.gz here"; \
	echo "  3) ln -s go_<date>-termdb-tables tables"; \
	echo "  4) type make again"; \
	exit 1


load.sql: $(wildcard tables/*.txt)
	perl -e 'while(my $$fn=shift) {' \
	-e 'my ($$t) = $$fn =~ m%(\w+)\.txt%;' \
	-e 'print "COPY go.$$t FROM '"'"'${PWD}/$$fn'"'"';\n";' \
	-e '}' $^ >$@.tmp \
	&& mv $@.tmp $@

go.pgdump.gz:
	pg_dump -O | gzip >$@.tmp && /bin/mv $@.tmp $@


.PHONY: clean cleaner cleanest
clean:
	/bin/rm -f *~ *.bak *.tmp
cleaner: clean
	/bin/rm -f godb.sql schema.sql load.sql
cleanest: cleaner
	/bin/rm -f tables godb.log
