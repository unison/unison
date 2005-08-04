.SUFFIXES:
.PHONY: FORCE

DIRS:=${HOME}/.mozilla/firefox/*/searchplugins

install:
	for d in ${DIRS}; do \
		/bin/cp -auv unison.src unison.png "$$d"; \
	done

uninstall:
	find ${DIRS} -name unison.\* -print0 | xargs -0rt /bin/rm -f
