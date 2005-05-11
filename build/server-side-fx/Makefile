.PHONY: FORCE

I=-I$(shell pg_config --includedir)/server

<<<<<<< Makefile
=======

DEST_DIR=$(shell pg_config --pkglibdir)

#PGDATA=/srv/postgresql
#DEST_DIR=${PGDATA}/lib


>>>>>>> 1.8
unison.so: unison.c
	gcc -shared -Wall  ${I} -o $@ -O2 -fpic $<

<<<<<<< Makefile

ifdef PGDATA

# I'd prefer to not install in the pkglibdir
# because that's part of the RPM tree
#D=$(shell pg_config --pkglibdir)
D=${PGDATA}/lib
install: $D/unison.so
$D/unison.so: unison.so
	/bin/cp -bv $< $@

else

install:
	# SET PGDATA IN ORDER TO INSTALL
	exit 2

endif

=======
install: ${DEST_DIR}/unison.so
${DEST_DIR}/unison.so: unison.so
	mkdir -p "${@D}"
	/bin/cp -bv "$<" "$@"
>>>>>>> 1.8


