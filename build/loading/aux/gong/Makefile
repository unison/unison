# -*-Makefile-*-

# Change these for your site:
MY2PG:=/apps/compbio/src/postgresql-7.3.2/contrib/mysql/my2pg.pl

# Set PGHOST, PGDATABASE, PGUSER before running this script


default all:
	@echo "There ain't no stinking default target, homey.  You may make:"; \
	echo "  load-go.sql -- the postgresql sql create-and-load script"; \
	echo "  load-go.log -- actually load the above"; \
	echo "  gong.log -- migrate GO term data to GOng"; \
	echo "  go.pgdump.gz -- get a pgdump of the go database"; \
	echo "  clean, cleaner, cleanest -- delete files (!DANGER!)"; \
	echo "I know it sounds strange, but consider reading the README file"; \
	exit 1


gong.log: gong.sql load-go.log
	psql -qaf $< | tee $@.tmp && /bin/mv $@.tmp $@

load-go.log: load-go.sql
	psql -qaf $< | tee $@.tmp && /bin/mv $@.tmp $@

load-go.sql: prep.sql schema.sql load.sql
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
	/bin/rm -f load-go.sql schema.sql load.sql
cleanest: cleaner
	/bin/rm -f tables load-go.log gong.log
