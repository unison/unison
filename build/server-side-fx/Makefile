.PHONY: FORCE

I=-I$(shell pg_config --includedir)/server

D=$(shell pg_config --pkglibdir)

unison.so: unison.c
	gcc -shared -Wall  ${I} -o $@ -O2 -fpic $<


install: $D/unison.so
$D/unison.so: unison.so
	/bin/cp -bv $< $@



#unison.so: unison.o
#	gcc -shared -o$@ $^
#
#%.o: %.c
#	gcc -Wall -c -o$@ -I/usr/include/pgsql/server -O2 -fpic $<
