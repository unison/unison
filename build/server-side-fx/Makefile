.PHONY: FORCE

I=-I$(shell pg_config --includedir)

D=$(shell pg_config --pkglibdir)

unison.so: unison.c FORCE
	gcc -shared -Wall  ${I} -o $@ -O2 -fpic $<

$D/unison.so: unison.so
	/bin/cp -bv $< $@


#unison.so: unison.o
#	gcc -shared -o$@ $^
#
#%.o: %.c
#	gcc -Wall -c -o$@ -I/usr/include/pgsql/server -O2 -fpic $<
