.PHONY: FORCE

../lib/unison.so: unison.c FORCE
	gcc -shared -Wall -o$@ -I/usr/include/pgsql/server -O2 -fpic $<

#unison.so: unison.o
#	gcc -shared -o$@ $^
#
#%.o: %.c
#	gcc -Wall -c -o$@ -I/usr/include/pgsql/server -O2 -fpic $<
