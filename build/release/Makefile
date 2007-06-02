# Unison release Makefile -- builds unison releases
# $Id: Makefile,v 1.18 2007/05/12 17:45:37 rkh Exp $

# Usage:
# eg$ make unison-1.0.0.tgz unison-1.0.0.tgz.md5 unison-1.0.0.tgz.asc
# eg$ make upload-1.0.0

# some rules must be run as the user 'postgres':
# eg$ sudo -u postgres make ...


.PHONY: FORCE
.SUFFIXES:
.DELETE_ON_ERROR:

export CVSROOT=/srv/cvs
export GZIP:=
DATE:=$(shell date +%Y%m%d)

export PGUSER:=postgres
#export PGHOST:=localhost
unexport PGDATABASE

STAGE_DATABASE=csb-stage


default all:
	@echo "Ain't no stinking $@ target" 1>&2; exit 1

.PHONY: pub
pub:
	sudo -u postgres make csb-pub.log PATH=${PATH} PERL5LIB=${PERL5LIB}

%-pub.log: 
	-dropdb $*-pub
	createdb -EUTF8 -Ounison $*-pub
	(time ~rkh/unison/tools/sbin/publicize $* | psql -d $*-pub -qa -f -) >$@.tmp 2>&1
	/bin/mv -f "$@.tmp" "$@"
	psql -d '$*-pub' -c 'alter database "$*-pub" set search_path = "$$user",unison,pdb,gong,scop,tax,public'
	psql -d '$*-pub' -c 'analyze verbose'

# run as postgres
%.pgdfc: %.log
	(time pg_dump -Fc $* >$@.tmp) 2>$@.err 
	/bin/mv -f "$@.tmp" "$@"

# NB: `./' is to prevent rsync from interpreting colons
# run as rkh
%-wepush: % %.md5
	(time rsync --progress ./$* ./$*.md5 we:tmp/) >$@.tmp 2>&1
	/bin/mv -f "$@.tmp" "$@"






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


# cant use 'cvs export' because I don't tag the prerequisites
.PHONY: perl5-prereq
perl5-prereq: perl5-prereq-${DATE}.tgz
perl5-prereq-${DATE}.tgz: %.tgz:
	mkdir /tmp/release-$$$$; cd /tmp/release-$$$$; set -x; \
	mkdir $*; \
	cvs co -d $* perl5/Bio perl5/CBT \
		&& tar --exclude CVS --exclude doc -czf ${PWD}/$@ $*; \
	rm -fr /tmp/release-$$$$


# "stage" the development database to production
# must be run on the database host
stage.log:
	export PGHOST=localhost PGUSER=postgres; \
	dropdb "${STAGE_DATABASE}" || true; \
	./dev2stage "${STAGE_DATABASE}" >$@.err 2>&1
	/bin/mv -f $@.err $@


# EXPERIMENTAL
stage2.log:
	( export PGHOST=localhost PGUSER=postgres; \
	dropdb csb-stage || true; \
	../../sbin/db-copy -S postgres,pgtools,public,go,gong,ncbi,pdb,scop,sst,tax,unison csb-dev csb-stage; \
	psql -d "csb-stage" -c "select meta_update_kv('staged at','`date +\"%Y-%m-%d %H:%M:%S\"`');" \
	) >$@.err 2>&1
	/bin/mv -f $@.err $@



# MANUAL INTERVENTION REQUIRED HERE
# admin must now rename the csb-stage to "csb" when ready


# build public database dumps
.PHONY: dump
dump: unison-${DATE}-schema.psql.gz unison-${DATE}-data.psql.gz
.PRECIOUS: csb-${DATE}.pgdump
%-${DATE}.pgdump:
	(time -p pg_dump -Fc $* >$@.tmp) 2>$@.err
	/bin/mv $@.err $@.log
	/bin/mv $@.tmp $@
.PRECIOUS: csb-${DATE}.psql
csb-%.psql.gz: csb-%.pgdump
	(pg_restore <$< | gzip -cq >$@.tmp) 2>$@.err
	/bin/mv $@.err $@.log
	/bin/mv $@.tmp $@
.PRECIOUS: unison-%-schema.psql.gz
unison-%-schema.psql.gz: csb-%.pgdump
	(pg_restore -s <$< | gzip >$@.tmp) 2>$@.err
	/bin/mv $@.err $@.log
	/bin/mv $@.tmp $@
.PRECIOUS: unison-%-data.psql.gz
unison-%-data.psql.gz: csb-%.psql.gz
	(time -p gzip -cdq <$< | ../../sbin/publicize | gzip >$@.tmp) 2>$@.err
	/bin/mv $@.err $@.log
	/bin/mv $@.tmp $@
unison-%-restore.log: unison-%-data.psql.gz
	-dropdb unison
	createdb unison
	gzip -cdq $< | time psql -dunison -qaf- >$@.err 2>&1
	/bin/mv $@.err $@


.PRECIOUS: %.md5
%.md5: %
	md5sum $< >"$@.tmp"
	/bin/mv -f "$@.tmp" "$@"

.PRECIOUS: %.asc
%.asc: %
	gpg -abs -o $@ $<

.PHONY: verify-%
verify-%: %.md5 %.asc
	md5sum -c $(word 1,$^)
	gpg --verify $(word 2,$^)

.PHONY: upload-%
upload-%: % %.md5 %.asc
	(echo cd incoming; echo prompt; echo mput $^) | /usr/bin/ftp -A ftp://ftp:reece-at-sf.net@upload.sf.net


.PHONY: clean cleaner cleanest
clean:
	/bin/rm -f *~ *.bak
cleaner: clean
	/bin/rm -f *.asc *.md5
cleanest: cleaner
	/bin/rm -f *.tgz
