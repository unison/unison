# Unison release Makefile -- builds unison releases
# $Id: Makefile,v 1.19 2007/06/02 03:44:20 rkh Exp $

# Unison release flow:
# dev -----1-----> stage -----2-----> prod -----3-----> public
# 1) "staging"
# a release candidate is built from the dev database and tested. 
# This database is built with 'make stage'
# The unison svn repo has a similar process for the API, tools, and web
# interface.
# 2) When the candidate has been tested, it's merely renamed to the
# production name. (e.g., csb-dev -> csb-stage -> csb)
# 3) "publicize-ation"
# An sql-format dump is built from a database (typically prod, but not
# necessarily).


.PHONY: FORCE
.SUFFIXES:
.DELETE_ON_ERROR:

export GZIP:=
DATE:=$(shell date +%Y%m%d)

#export PGUSER:=postgres
#export PGHOST:=localhost
unexport PGUSER
unexport PGDATABASE

DEST_PGHOST=research-pub
DEST_PGUSER=rkh
DEST_PGFLAGS=-h${DEST_PGHOST} -U${DEST_PGUSER}

STAGE_DATABASE=csb-stage

PG_SUDO:=sudo -u postgres env PERL5LIB=${PERL5LIB} PATH=${PATH}


default all:
	@echo "Ain't no stinking $@ target" 1>&2; exit 1


# "stage" the development database to production
# must be run on the database host
stage.log:
	export PGHOST=localhost PGUSER=postgres; \
	dropdb "${STAGE_DATABASE}" || true; \
	../../tools/sbin/dev2stage "${STAGE_DATABASE}" >$@.err 2>&1
	/bin/mv -f $@.err $@

# build public version as an sql dump file
.PRECIOUS: %-pub.sql.gz
%-pub.sql.gz:
	(time ${PG_SUDO} ../../tools/sbin/publicize $* \
	| grep -v 'CONSTRAINT sty_residue CHECK' \
	| gzip -c >$@ ) >$@.err 2>&1
	/bin/mv -f "$@.err" "$@.log"

.PHONY: %-respub-push
%-respub-push: % %.md5
	rsync --progress -HRav $^ respub:/data/www/htdocs/unison/dumps/

# load the dump file into the destination database
%-${DEST_PGHOST}-load.log: %.sql.gz
	createdb -EUTF8 -Ounison ${DEST_PGFLAGS} $*
	(gzip -cdq <$< | time -p psql -X ${DEST_PGFLAGS} -d $* -qaf-) >$@.err 2>&1

# dump arbitrary database as postgresql "custom" dump format
.PRECIOUS: %.pgdfc
%.pgdfc: %.log
	(time ${PG_SUDO} pg_dump -Fc $* >$@.tmp) 2>$@.err 
	/bin/mv -f "$@.tmp" "$@"

.PRECIOUS: %.md5
%.md5: %
	md5sum "$<" >"$@.tmp"
	/bin/mv -f "$@.tmp" "$@"

%.asc: %
	gpg -abs -o $@ $<

.PHONY: %-verify
%-verify: %.md5 %.asc
	md5sum -c $(word 1,$^)
	gpg --verify $(word 2,$^)


.PHONY: clean cleaner cleanest
clean:
	/bin/rm -f *~ *.bak
cleaner: clean
	/bin/rm -f *.asc *.md5
cleanest: cleaner
	/bin/rm -f *.tgz *pushlog *.log
	/bin/rm -fr *.d





### # Build public version on same machine as source
### .PRECIOUS: %-pub.log
### %-pub.log: 
### 	( -dropdb $*-pub; \
### 	createdb -EUTF8 -Ounison $*-pub; \
### 	${PG_SUDO} ../../tools/sbin/publicize $* \
### 	| grep -v 'CONSTRAINT sty_residue CHECK' \
### 	| psql -X -d $*-pub -qa -f -; \
### 	psql -d '$*-pub' -c 'alter database "$*-pub" set search_path = "$$user",unison,pdb,gong,scop,tax,public'; \
### 	) >$@.tmp 2>&1
### 	/bin/mv -f "$@.tmp" "$@"
### 
### # Build public version on research-pub from local instance
### # Reminder: requires password from ~/.pgpass or PGPASSWORD
### %-respub-install.log:
### 	@[ "`id -un`" = "rkh" ] || { echo "You're not Reece -- good luck" 1>&2; exit 1; }
### 	createdb -EUTF8 -Ounison -h research-pub.gene.com $*-pub
### 	( ${PG_SUDO} ../../tools/sbin/publicize -h respgsql $* \
### 	| grep -v 'CONSTRAINT sty_residue CHECK' \
### 	| time -p psql -X -h research-pub.gene.com -d $*-pub -qaf-) >$@.err 2>&1
### 
### 
### # file-split is in Reece's directory. This will fail if you're not me.
### %.d: %
### 	file-split $<
### 
### %-push: 
### 	@[ `id -u` == 13922 ] || { echo "You're not Reece; this is guaranteed to fail" 1>&2; exit 1; }
### 	ssh-agent /bin/sh -c 'ssh-add; make $*.pushlog'
