# Unison release Makefile -- builds unison releases
# $Id$

# Usage:
# eg$ make unison-1.0.0.tgz unison-1.0.0.tgz.md5 unison-1.0.0.tgz.asc
# eg$ make upload-1.0.0


export CVSROOT=geneland:/usr/local/cvs
export GZIP:=

default all:
	@echo "Ain't no stinking $@ target" 1>&2; exit 1

.PHONY: unison-%.tgz
unison-%.tgz:
	@RTAG=`echo "rel_$*" | sed -e 's/\./-/g'`; \
	mkdir /tmp/release-$$$$; cd /tmp/release-$$$$; set -x; \
	cvs co -r"$$RTAG" -d unison-$* unison && tar -czf ${PWD}/$@ unison-$*; \
	rm -fr /tmp/release-$$$$

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
