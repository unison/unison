.PHONY: FORCE

I=-I$(shell pg_config --includedir)/server

unison.so: unison.c
	gcc -shared -Wall  ${I} -o $@ -O2 -fpic $<


PGDATA=/srv/postgresql

ifdef PGDATA

# I'd prefer to not install in the pkglibdir
# because that's part of the RPM tree
#D=$(shell pg_config --pkglibdir)
D=${PGDATA}/lib
install: $D/unison.so
$D/unison.so: unison.so
	mkdir -p "${@D}"
	/bin/cp -bv "$<" "$@"

else

install:
	# SET PGDATA IN ORDER TO INSTALL
	exit 2

endif



#unison.so: unison.o
#	gcc -shared -o$@ $^
#
#%.o: %.c
#	gcc -Wall -c -o$@ -I/usr/include/pgsql/server -O2 -fpic $<
