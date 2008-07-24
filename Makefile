.SUFFIXES:
.PHONY: FORCE
#.DELETE_ON_ERROR:

default:
	@echo "There ain't no stinkin' default target" 1>&2; exit 1

.PHONY: ignore-reset
ignore-reset:
	svn propset -R svn:ignore -F .svnignore  .


## The following are bad hacks and should be replaced.
# consider writing: 1) a script to identify perl files (executable or not,
# with and without .p[lm] suffixes; 2) ditto for shell; 3) .html files
# 1 gets run through perltidy
# 1+2+3 are candidates for propset

.PHONY: perltidy
perl-files.ls:
	(find .                    -type f -name \*.p[lm];  \
	 find tools/bin tools/sbin -type f -perm /ugo+x   ) \
	| grep -v '~$' \
	| sort -u >$@

perltidy: perl-files.ls
	tr \\012 \\0 <$< \
	| xargs -0r perltidy --profile=unison.perltidy -b

## .PHONY: propset
## propset:
## 	# WARNING: You should be using svn auto-props in ~/.subversion/config .
## 	( \
## 	find . \( -name \*.p[lm] -o -name \*.html \) -type f -print; \
## 	find tools/bin tools/sbin -type f -perm /ugo+x \! -name *~
## 	) \
## 	| grep -v /dead/ \
## 	| tr \\012 \\0 \
## 	| xargs -0rt svn propset svn:keywords 'Date Id Revision'


precommit:
	make -C build csb-dev.sql


install: .svnversion
.svnversion: FORCE
	svnversion >$@


SVN2CL_OPTS=--group-by-day
ChangeLog:
	svn2cl -o $@ ${SVN2CL_OPTS}
ChangeLog.html:
	svn2cl -o $@ ${SVN2CL_OPTS} --html
# consider dated logs w/ -r '{2006-01-01}:{2005-01-01}'


.PHONY: clean cleaner cleanest
clean:
	rm -f *.log
cleaner: clean
	find . \( -name \*~ -o -name \*.bak \) -print0 | xargs -0rt rm -f
cleanest: cleaner
