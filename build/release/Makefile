# Unison release Makefile -- builds unison releases
# $Id: Makefile,v 1.1 2005/06/15 01:47:23 rkh Exp $

# Usage:
# eg$ make unison-1.0.0.tgz unison-1.0.0.tgz.md5 unison-1.0.0.tgz.asc
# eg$ make upload-1.0.0

export CVSROOT=geneland:/usr/local/cvs
export GZIP:=
PATH:=${HOME}/csb-db/sbin:${PATH}
DATE:=$(shell date +%Y%m%d)

default all:
	@echo "Ain't no stinking $@ target" 1>&2; exit 1

.PHONY: unison-web-%.tgz
unison-web-%.tgz:
	@RTAG=`echo "rel_$*" | sed -e 's/\./-/g'`; \
	mkdir /tmp/release-$$$$; cd /tmp/release-$$$$; set -x; \
	cvs co -r"$$RTAG" -d unison-web-$* unison-web && tar -czf ${PWD}/$@ unison-web-$*; \
	rm -fr /tmp/release-$$$$

.PHONY: unison-%.tgz
unison-%.tgz:
	@RTAG=`echo "rel_$*" | sed -e 's/\./-/g'`; \
	mkdir /tmp/release-$$$$; cd /tmp/release-$$$$; set -x; \
	cvs co -r"$$RTAG" -d unison-$* unison && tar -czf ${PWD}/$@ unison-$*; \
	rm -fr /tmp/release-$$$$

.PHONY: dump
dump: unison-pgdump-${DATE}.psql.gz
unison-pgdump-${DATE}.psql.gz: unison.pgdump
	(pg_restore $< | make-csb-public | gzip >$@.tmp) 2>$@.err
	/bin/mv $@.err $@.log
	/bin/mv $@.tmp $@

.PHONY: unison-%.tgz.md5
%.md5: %
	md5sum $< >$@.tmp
	/bin/mv -f $@.tmp $@

.PHONY: unison-%.tgz.asc
%.asc: %
	gpg -abs -o $@ $<


verify-%: unison-%.tgz unison-%.tgz.asc unison-%.tgz.md5
	md5sum -c unison-$*.tgz.md5
	gpg --verify unison-$*.tgz.asc

upload-%: unison-%.tgz unison-%.tgz.asc unison-%.tgz.md5
	(echo cd incoming; echo prompt; echo mput $^) | /usr/bin/ftp -A ftp://ftp:reece-at-sf.net@upload.sf.net



.PHONY: clean cleaner cleanest
clean:
	/bin/rm -f *~ *.bak
cleaner: clean
	/bin/rm -f *.asc *.md5
cleanest: cleaner
	/bin/rm -f *.tgz
