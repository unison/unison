.SUFFIXES:
.PHONY: FORCE
#.DELETE_ON_ERROR:

default:
	@echo "There ain't no stinkin' default target" 1>&2; exit 1

perltidy.log: %:
	(time -p find . -name \*.p[lm] -type f | head | xargs perltidy -b) >$*.err 2>&1
	/bin/mv -f $*.err $@

.PHONY: propset-Id
propset:
	find . \( -name \*.p[lm] -o -name \*.html \) -type f -print | grep -v /dead/ | tr \\012 \\0 | xargs -0rt svn propset svn:keywords 'Date Id Revision'


.PHONY: clean cleaner cleanest
clean:
	rm -f *.log
cleaner: clean
	find . \( -name \*~ -o -name \*.bak \) -print0 | xargs -0rt rm -f
cleanest: cleaner
