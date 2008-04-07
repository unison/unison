.PHONY: FORCE

I=-I$(shell pg_config --includedir)/server

DEST_DIR=$(shell pg_config --pkglibdir)
#PGDATA=/srv/postgresql-8.2
#DEST_DIR=${PGDATA}/lib

unison.so: unison.c
	gcc -shared -Wall  ${I} -o $@ -O2 -fpic $<

install: ${DEST_DIR}/unison.so
${DEST_DIR}/unison.so: unison.so
	mkdir -p "${@D}"
	/bin/cp -bv "$<" "$@"

clean:
	/bin/rm -f *~
cleaner: clean
cleanest: cleaner
	/bin/rm -f *.so
