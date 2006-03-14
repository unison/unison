.SUFFIXES:
.PHONY: FORCE

DIRS:=${HOME}/.mozilla/firefox/*/searchplugins
DEV_BASE:=http://csb:8080/~rkh/csb/unison/

unison-dev.src: unison.src Makefile
	perl -pe 's%http://unison-db.org/%${DEV_BASE}%; s/unison.(src|png)/unison-dev.$$1/g;' $< >$@

# warning: gratuitous use of ImageMagick ahead...
unison-dev.png: unison.png Makefile
	convert -font helvetica-oblique -pointsize 12 -fill blue \
		-draw "text 7,15 d" \
		-draw "text 7,16 d" \
		-draw "text 8,15 d" \
		-draw "text 8,16 d" \
	$< $@

install: unison.src unison.png unison-dev.src unison-dev.png
	for d in ${DIRS}; do \
		/bin/cp -auv $^ "$$d"; \
	done

uninstall:
	find ${DIRS} -name unison.\* -print0 | xargs -0rt /bin/rm -f
