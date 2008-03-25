## unison styles
# This makefile builds the unison.css stylesheet from a m4 template and a
# key-value `colorset' file (.cs).  The intent is to play with colors
# until I (Reece) find something I like, which I haven't yet.

.SUFFIXES:
.PHONY: FORCE
.DELETE_ON_ERROR:

CS:=light-pastel


default: unison.css

all: $(foreach C,$(subst .cs,,$(wildcard *.cs)),unison-$C.css)


%.cs: unison.css.m4
	./rewrite-cs <$@ >.$@
	/bin/mv -b .$@ $@

unison.css.m4:;

%.m4: %.cs
	perl -laF= -ne 'print("define(\`$$F[0]\047,\`$$F[1]\047)")' <$< >$@

unison-%.css: %.m4 unison.css.m4
	m4 -DPALETTE=$* $^ >$@

unison.css: unison-${CS}.css
	cp -b $< $@


.PHONY: clean cleaner cleanest
clean:
	/bin/rm -f *~
cleaner: clean
	/bin/rm -f *.bak
cleanest: cleaner
	/bin/rm -f *.css
