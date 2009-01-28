# Unison release Makefile -- builds unison releases
# $Id: Makefile,v 1.19 2007/06/02 03:44:20 rkh Exp $

# Usage:
# eg$ make unison-1.0.0.tgz unison-1.0.0.tgz.md5 unison-1.0.0.tgz.asc
# eg$ make upload-1.0.0

# some rules must be run as the user 'postgres':
# eg$ sudo -u postgres make ...


.PHONY: FORCE
.SUFFIXES:
.DELETE_ON_ERROR:

export GZIP:=
DATE:=$(shell date +%Y%m%d)

#export PGUSER:=postgres
#export PGHOST:=localhost
unexport PGUSER
unexport PGDATABASE

STAGE_DATABASE=csb-stage
PG_SUDO:=sudo -u postgres env PERL5LIB=${PERL5LIB} PATH=${PATH}


default all:
	@echo "Ain't no stinking $@ target" 1>&2; exit 1


.PRECIOUS: %-pub.log
%-pub.log: 
	( -dropdb $*-pub; \
	createdb -EUTF8 -Ounison $*-pub; \
	time ${PG_SUDO} ../../tools/sbin/publicize $* | psql X -d $*-pub -qa -f -; \
	psql -d '$*-pub' -c 'alter database "$*-pub" set search_path = "$$user",unison,pdb,gong,scop,tax,public'; \
	psql -d '$*-pub' -c 'analyze verbose'; \
	) >$@.tmp 2>&1
	/bin/mv -f "$@.tmp" "$@"


.PRECIOUS: %-pub.sql.gz
%-pub.sql.gz:
	(time ${PG_SUDO} ../../tools/sbin/publicize $* \
	| grep -v 'CONSTRAINT sty_residue CHECK' \
	| gzip -c >$@ ) >$@.err 2>&1
	/bin/mv -f "$@.err" "$@.log"


# Reminder: requires password from ~/.pgpass or PGPASSWORD
%-pub-push.log:
	@[ "`id -un`" = "rkh" ] || { echo "You're not Reece; this is guaranteed to fail" 1>&2; exit 1; }
	createdb -h research-pub.gene.com $*-pub
	( ${PG_SUDO} ../../tools/sbin/publicize -h respgsql $* \
	| grep -v 'CONSTRAINT sty_residue CHECK' \
	| time -p psql -X -h research-pub.gene.com -d $*-pub -qaf-) >$@.err 2>&1


%-push: 
	@[ `id -u` == 13922 ] || { echo "You're not Reece; this is guaranteed to fail" 1>&2; exit 1; }
	ssh-agent /bin/sh -c 'ssh-add; make $*.pushlog'

# run as postgres
.PRECIOUS: %.pgdfc
%.pgdfc: %.log
	(time ${PG_SUDO} pg_dump -Fc $* >$@.tmp) 2>$@.err 
	/bin/mv -f "$@.tmp" "$@"



# file-split is in Reece's directory. This will fail if you're not me.
%.d: %
	file-split $<

# NB: `./' is to prevent rsync from interpreting colons in timestamps
# run as rkh
%.pushlog: %
	(time rsync -av --progress ./$< we:) >$@.tmp 2>&1
	/bin/mv -f "$@.tmp" "$@"





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
	../../tools/sbin/dev2stage "${STAGE_DATABASE}" >$@.err 2>&1
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
	(time -p gzip -cdq <$< | ../../tools/sbin/publicize | gzip >$@.tmp) 2>$@.err
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
	/bin/rm -f *.tgz *pushlog *.log
	/bin/rm -fr *.d
