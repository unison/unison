.SUFFIXES:
.PHONY: FORCE
.DELETE_ON_ERROR:


default:
	@echo "no $@ target" 1>&2; exit 1


SS:=ss-aliases.png ss-features.png ss-functions.png ss-loci.png ss-patents.png ss-structure.png ss-summary.png

update: $(SS:.png=-sm.png) concept-graphic-med.jpg results-cube-med.jpg


# "small" images intended as icons/thumbnails
# aim for 100px max in larger dimension w/moderate quality
# in practice, this results in images 5-10KB
%-sm.jpg: %.jpg
	convert -geometry 100x100 -quality 40 $< $@
%-sm.png: %.png
	convert -geometry 100x100 -quality 40 $< $@


# "medium" images intended for legible inset graphics
# aim for 500x500 w/moderate quality and sizes
# in practice, this results in images 20-40KB
%-med.jpg: %.jpg
	convert -geometry 500x500 -quality 60 $< $@
%-med.png: %.png
	convert -geometry 500x500 -quality 60 $< $@
