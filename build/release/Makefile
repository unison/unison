# Unison release Makefile -- builds unison releases
# $Id: Makefile,v 1.5 2005/06/21 23:46:34 rkh Exp $

# Usage:
# eg$ make unison-1.0.0.tgz unison-1.0.0.tgz.md5 unison-1.0.0.tgz.asc
# eg$ make upload-1.0.0

export CVSROOT=geneland:/usr/local/cvs
export GZIP:=
DATE:=$(shell date +%Y%m%d)

export PGUSER:=postgres
export PGHOST:=localhost
unexport PGDATABASE


default all:
	@echo "Ain't no stinking $@ target" 1>&2; exit 1


# build a tarball of the web pages
# NOTE: this rule must be before unison-%.tgz
# should use 'cvs export'
.PHONY: unison-web-%.tgz
unison-web-%.tgz:
	@RTAG=`echo "rel_$*" | sed -e 's/\./-/g'`; \
	mkdir /tmp/release-$$$$; cd /tmp/release-$$$$; set -x; \
	cvs co -r"$$RTAG" -d unison-web-$* unison-web \
		&& tar --exclude CVS -czf ${PWD}/$@ unison-web-$*; \
	rm -fr /tmp/release-$$$$


# build a tarball of a specific release
# should use 'cvs export'
.PHONY: unison-%.tgz
unison-%.tgz:
	@RTAG=`echo "rel_$*" | sed -e 's/\./-/g'`; \
	mkdir /tmp/release-$$$$; cd /tmp/release-$$$$; set -x; \
	cvs co -r"$$RTAG" -d unison-$* unison \
		&& tar --exclude CVS -czf ${PWD}/$@ unison-$*; \
	rm -fr /tmp/release-$$$$


# cant use 'cvs export' because I don't tag these
.PHONY: perl5-prereq
perl5-prereq: perl5-prereq-${DATE}.tgz
perl5-prereq-${DATE}.tgz: %.tgz:
	mkdir /tmp/release-$$$$; cd /tmp/release-$$$$; set -x; \
	mkdir $*; \
	cvs co -d $* perl5/Bio perl5/CBT \
		&& tar --exclude CVS --exclude doc -czf ${PWD}/$@ $*; \
	rm -fr /tmp/release-$$$$


# "stage" the development database to production
stage.log:
	export PGHOST=localhost PGUSER=postgres; \
	dropdb csb-stage || true; \
	../../sbin/dev2stage csb-stage >$@ 2>&1


# build public database dumps
.PHONY: dump
dump: unison-${DATE}-schema.psql.gz unison-${DATE}-data.psql.gz
unison-${DATE}-data.psql.gz:
	(pg_dump csb $< | ../../sbin/publicize -dcsb-dev | gzip >$@.tmp) 2>$@.err
	/bin/mv $@.err $@.log
	/bin/mv $@.tmp $@
unison-${DATE}-schema.psql.gz:
	(pg_dump -s csb $< | gzip >$@.tmp) 2>$@.err
	/bin/mv $@.err $@.log
	/bin/mv $@.tmp $@
unison-%-restore.log: unison-%-data.psql.gz
	-dropdb unison
	createdb unison
	gzip -cdq $< | time psql -dunison -qaf- >$@.err 2>&1
	/bin/mv $@.err $@

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
upload-%: % %.md5 # %.asc
	(echo cd incoming; echo prompt; echo mput $^) | /usr/bin/ftp -A ftp://ftp:reece-at-sf.net@upload.sf.net



## ## WARNING: the branch-% and release-% targets are being tested
## branch-%:
## 	@BRTAG=`echo "br_$*" | sed -e 's/\./-/g; s/-[0-9][0-9]*$$//;'`; \
## 	set -x; \
## 	cvs up -A; \
## 	cvs tag "$$BRTAG-root"; \
## 	cvs rtag -r "$$BRTAG-root" "$$BRTAG"; \
## 	cvs up -r "$$BRTAG"
## 
## release-%:
## 	@BRTAG=`echo "br_$*" | sed -e 's/\./-/g; s/-[0-9][0-9]*$$//;'`; \
## 	RTAG=`echo "rel_$*" | sed -e 's/\./-/g'`; \
## 	set -x; \
## 	cvs up -r "$$BRTAG"; \
## 	cvs tag "$$RTAG"


.PHONY: clean cleaner cleanest
clean:
	/bin/rm -f *~ *.bak
cleaner: clean
	/bin/rm -f *.asc *.md5
cleanest: cleaner
	/bin/rm -f *.tgz


