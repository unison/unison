.SUFFIXES:
.PHONY: FORCE
.DELETE_ON_ERROR:


default:
	@echo "no $@ target" 1>&2; exit 1


SS:=ss-aliases.png ss-features.png ss-functions.png ss-loci.png ss-patents.png ss-structure.png ss-summary.png

update: $(SS:.png=-sm.jpg) concept-graphic-med.jpg results-cube-med.jpg


# "small" images intended as icons/thumbnails
# aim for 100px max in larger dimension w/moderate quality
# in practice, this results in images 5-10KB
CONVERT_SM_OPTS:= -geometry 100x100 -quality 40
%-sm.jpg %-sm.png: %.jpg
	convert ${CONVERT_SM_OPTS} $< $@
%-sm.jpg %-sm.png: %.png
	convert ${CONVERT_SM_OPTS} $< $@


# "medium" images intended for legible inset graphics
# aim for 500x500 w/moderate quality and sizes
# in practice, this results in images 20-40KB
CONVERT_MED_OPTS:=-antialias -geometry 500x500 -quality 60
%-med.jpg %-med.png: %.jpg
	convert ${CONVERT_MED_OPTS} $< $@
%-med.jpg %-med.png: %.png
	convert ${CONVERT_MED_OPTS} $< $@
