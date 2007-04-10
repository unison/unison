.SUFFIXES:
.PHONY: FORCE

DIRS:=${HOME}/.mozilla/firefox/*/searchplugins
USER:=$(shell /usr/bin/id -nu)

DEV_BASE:=http://csb:8080/unison/
USER_BASE:=http://csb:8080/~$USER/unison/


TARGETS:=unison.src unison.png $(foreach d,dev gne user,unison-$d.src unison-$d.png)

.PHONY: all
all: ${TARGETS}


unison-gne.src: unison.src Makefile
	perl -pe 's%http://unison-db.org/%${GNE_BASE}%; s/unison.(src|png)/unison-gne.$$1/g;' $< >$@

unison-gne.png: unison.png Makefile
	convert -font helvetica-oblique -pointsize 9 -fill blue \
		-draw "text 0,13 gne" \
	$< $@


unison-dev.src: unison.src Makefile
	perl -pe 's%http://unison-db.org/%${DEV_BASE}%; s/unison.(src|png)/unison-dev.$$1/g;' $< >$@

unison-dev.png: unison.png Makefile
	convert -font helvetica-oblique -pointsize 9 -fill blue \
		-draw "text 0,13 dev" \
	$< $@


unison-user.src: unison.src Makefile
	perl -pe 's%http://unison-db.org/%${USER_BASE}%; s/unison.(src|png)/unison-user.$$1/g;' $< >$@

unison-user.png: unison.png Makefile
	convert -font helvetica-oblique -pointsize 18 -fill blue \
		-draw "text 0,15 ~" \
		-draw "text 0,16 ~" \
		-draw "text 1,15 ~" \
		-draw "text 1,16 ~" \
	$< $@



install: all
	for d in ${DIRS}; do \
		/bin/cp -auv $^ "$$d"; \
	done

uninstall:
	find ${DIRS} -name unison.\* -print0 | xargs -0rt /bin/rm -f


.PHONY: clean cleaner cleanest
clean:
cleaner: clean
	/bin/rm -f unison-{dev,gne,user}.*
cleanest: cleaner