# -*-Makefile-*-
MY2PG:=/apps/compbio/src/postgresql-7.3.2/contrib/mysql/my2pg.pl
export PGHOST=td-svc


default all:
	@echo "There ain't no stinking default target, homey.  You may make:"; \
	echo "  godb.sql -- the postgresql sql create-and-load script"; \
	echo "  godb.log -- actually load the above"; \
	echo "  go.pgdump.gz -- get a pgdump of the go database";
	exit 1


godb.log: load.sql
	psql -Uadmin -dgo -qaf $< | tee $@.tmp
	/bin/mv $@.tmp $@

godb.sql: prep.sql schema.sql load.sql
	cat $^ >$@

schema.sql:: tables
schema.sql:: $(wildcard tables/*.sql)
	(cd tables; ${MY2PG} *.sql) >$@
tables:
	@echo "you need to:"; \
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
	pg_dump -dgo | gzip >$@.tmp
	/bin/mv $@.tmp $@


.PHONY: clean cleaner cleanest
clean:
	/bin/rm -f *~ *.bak *.tmp
cleaner: clean
	/bin/rm -f godb.sql schema.sql load.sql
cleanest: cleaner
	/bin/rm -f tables
