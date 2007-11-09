.SUFFIXES:
.PHONY: FORCE
#.DELETE_ON_ERROR:

default:
	@echo "There ain't no stinkin' default target" 1>&2; exit 1


## The following are bad hacks and should be replaced.
# consider writing: 1) a script to identify perl files (executable or not,
# with and without .p[lm] suffixes; 2) ditto for shell; 3) .html files
# 1 gets run through perltidy
# 1+2+3 are candidates for propset

## .PHONY: perltidy
## perltidy:
## 	(find .                    -type f \! -name \*~ -name \*.p[lm];  \
## 	 find tools/bin tools/sbin -type f \! -name \*~ -perm /ugo+x   ) \
## 	| sort -u
## # \
## #	| tr \\012 \\0 \
## #	xargs -0r perltidy --profile=unison.perltidy -b
## 
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


.PHONY: clean cleaner cleanest
clean:
	rm -f *.log
cleaner: clean
	find . \( -name \*~ -o -name \*.bak \) -print0 | xargs -0rt rm -f
cleanest: cleaner
