.PHONY: FORCE


I=-I$(shell pg_config --includedir)

D=$(shell pg_config --pkglibdir)

$D/unison.so: unison.so
	/bin/cp -bv $< $@

unison.so: unison.c FORCE
	gcc -shared -Wall -o $@ ${I} -O2 -fpic $<


#unison.so: unison.o
#	gcc -shared -o$@ $^
#
#%.o: %.c
#	gcc -Wall -c -o$@ -I/usr/include/pgsql/server -O2 -fpic $<
