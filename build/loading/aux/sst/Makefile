include ../defaults.mk

default all: log

sst.log: sst.sql
	(time -p psql -qf sst.sql) >$@.tmp 2>$@.err \
	&& /bin/mv -f $@.err $@.log && /bin/mv -f $@.tmp $@

sst.sql:
	(time -p sst-import >$@.tmp) 2>$@.err \
	&& /bin/mv -f $@.err $@.log && /bin/mv -f $@.tmp $@


cleaner: clean
cleanest: cleaner
