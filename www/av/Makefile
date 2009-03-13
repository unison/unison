.SUFFIXES:
.PHONY: FORCE
.DELETE_ON_ERROR:


default:
	@echo "no $@ target" 1>&2; exit 1


SS:=ss-aliases.png ss-features.png ss-functions.png ss-loci.png ss-patents.png ss-structure.png ss-summary.png

update: $(SS:.png=-sm.jpg) concept-graphic-med.gif results-cube-med.gif


%.gif: %.jpg
	convert $< $@
%.gif: %.png
	convert $< $@


# "small" images intended as icons/thumbnails
# aim for 100px max in larger dimension w/moderate quality
# in practice, this results in most images ~5-10KB
CONVERT_SM_OPTS:= -geometry 100x100 -quality 40
%-sm.jpg %-sm.png: %.jpg
	convert ${CONVERT_SM_OPTS} $< $@
%-sm.jpg %-sm.png: %.png
	convert ${CONVERT_SM_OPTS} $< $@


# "medium" images intended for legible inset graphics
# aim for 500x500 w/moderate quality and sizes
# in practice, this results in most images ~20-40KB
MED_GEOMETRY:=-geometry 500x500
CONVERT_MED_OPTS:=-antialias -quality 60
%-med.jpg %-med.png: %.jpg
	convert ${MED_GEOMETRY} ${CONVERT_MED_OPTS} $< $@
%-med.gif %-med.jpg %-med.png: %.png
	convert ${MED_GEOMETRY} ${CONVERT_MED_OPTS} $< $@
%-med.gif %-med.jpg %-med.png: %.gif
	convert ${MED_GEOMETRY} ${CONVERT_MED_OPTS} $< $@
%-med.gif: %.jpg
	convert ${MED_GEOMETRY} $< $@
%-med.gif: %.png
	convert ${MED_GEOMETRY} -antialias $< $@



# find files that use each of the graphics in av
# The intent is to help find unused or redundant (same image, different
# format) graphics
# grep -v www/av/$$g -- because some graphics have filename embedded!
/tmp/av-uses:
	/bin/ls -1 *.gif *.jpg *.png *.xpm | sort \
	| ( cd ../../; \
	while read g; do \
		echo "# $$g"; \
		find doc misc perl5 tools www \( -name tmp -o -name .svn \) -prune -o -type f \! -name \*~ -print0 \
		| xargs -0r /bin/grep -rls "$$g" \
		| grep -v "www/av/$$g" \
		| sed -e "s/^/$$g:/"; \
	done ) >$@
/tmp/av-use-summary: /tmp/av-uses
	perl -ne 'if (m/^# (.+)/) { $$c{$$1}=0; } elsif (m/^([^:]+):/) { $$c{$$1}++ }  END { printf("%3d $$_\n",$$c{$$_}) for sort keys %c}' <$< >$@ 
