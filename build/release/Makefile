# Unison release Makefile -- builds unison releases
# $Id: Makefile,v 1.2 2005/06/15 03:49:04 rkh Exp $

# Usage:
# eg$ make unison-1.0.0.tgz unison-1.0.0.tgz.md5 unison-1.0.0.tgz.asc
# eg$ make upload-1.0.0

export CVSROOT=geneland:/usr/local/cvs
export GZIP:=
DATE:=$(shell date +%Y%m%d)
unexport PGDATABASE
unexport PGUSER
unexport PGHOST

default all:
	@echo "Ain't no stinking $@ target" 1>&2; exit 1

upload: 

.PHONY: unison-%.tgz
unison-%.tgz:
	@RTAG=`echo "rel_$*" | sed -e 's/\./-/g'`; \
	mkdir /tmp/release-$$$$; cd /tmp/release-$$$$; set -x; \
	cvs co -r"$$RTAG" -d unison-$* unison \
		&& tar -czf ${PWD}/$@ unison-$*; \
	rm -fr /tmp/release-$$$$

.PHONY: dump
dump: unison-${DATE}-schema.psql.gz unison-${DATE}-data.psql.gz
unison-${DATE}-data.psql.gz:
	(pg_dump -Upostgres -hcsb csb $< | sbin/make-csb-public | gzip >$@.tmp) 2>$@.err
	/bin/mv $@.err $@.log
	/bin/mv $@.tmp $@
unison-${DATE}-schema.psql.gz:
	(pg_dump -Upostgres -s -hcsb csb $< | sbin/make-csb-public | gzip >$@.tmp) 2>$@.err
	/bin/mv $@.err $@.log
	/bin/mv $@.tmp $@



%.md5: %
	md5sum $< >$@.tmp
	/bin/mv -f $@.tmp $@

%.asc: %
	gpg -abs -o $@ $<

.PHONY: verify-%
verify-%: %.md5 %.asc
	md5sum -c $(word 1,$^)
	gpg --verify $(word 2,$^)

.PHONY: upload-%
upload-%: % %.asc %.md5
	(echo cd incoming; echo prompt; echo mput $^) | /usr/bin/ftp -A ftp://ftp:reece-at-sf.net@upload.sf.net



## WARNING: the branch-% and release-% targets are being tested
branch-%:
	@BRTAG=`echo "br_$*" | sed -e 's/\./-/g; s/-[0-9][0-9]*$$//;'`; \
	set -x; \
	cvs up -A; \
	cvs tag "$$BRTAG-root"; \
	cvs rtag -r "$$BRTAG-root" "$$BRTAG"; \
	cvs up -r "$$BRTAG"

release-%:
	@BRTAG=`echo "br_$*" | sed -e 's/\./-/g; s/-[0-9][0-9]*$$//;'`; \
	RTAG=`echo "rel_$*" | sed -e 's/\./-/g'`; \
	set -x; \
	cvs up -r "$$BRTAG"; \
	cvs tag "$$RTAG"


.PHONY: clean cleaner cleanest
clean:
	/bin/rm -f *~ *.bak
cleaner: clean
	/bin/rm -f *.asc *.md5
cleanest: cleaner
	/bin/rm -f *.tgz


# .PHONY: unison-web-%.tgz
# unison-web-%.tgz:
# 	@RTAG=`echo "rel_$*" | sed -e 's/\./-/g'`; \
# 	mkdir /tmp/release-$$$$; cd /tmp/release-$$$$; set -x; \
# 	cvs co -r"$$RTAG" -d unison-web-$* unison-web && tar -czf ${PWD}/$@ unison-web-$*; \
# 	rm -fr /tmp/release-$$$$

