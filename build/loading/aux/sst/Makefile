
default all: sst.log

include ../defaults.mk


sst.log: sst.sql
	(time -p psql -Uunison -qf sst.sql) >$@.err 2>&1 \
	&& /bin/mv -f $@.err $@


.PRECIOUS: sst.sql
sst.sql:
	(time -p sst-import >$@.tmp) 2>$@.err \
	&& /bin/mv -f $@.err $@.log && /bin/mv -f $@.tmp $@


cleaner: clean
	/bin/rm -f sst.sql*
cleanest: cleaner
	/bin/rm -f sst.log*
