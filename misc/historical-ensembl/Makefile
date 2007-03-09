# historical-ensembl Makefile

default all: update

PATH:=../../build/loading/bin:${PATH}

include ../../build/loading/common.mk
#include ../../build/loading/local.mk
#include ../../build/loading/params.mk



ls-lR.gz:
	wget -nd ftp://ftp.ensembl.org/ls-lR.gz

# WARNING: lslR-to-full-path is in Reece's home dir
urls: ls-lR.gz
	gzip -cd <$< \
	| perl -ln \
		-e 'if (m/^(.+):$$/) {' \
		-e   '$$root=$$1;' \
		-e '}' \
		-e 'elsif (m/^\S+\s+\d+\s+\S+\s+\S+\s+\d+\s+\d{4}-\d{2}-\d{2}\s+\d+:\d+\s+(.+)/) {'\
		-e   'my $$p="$$root/$$1";' \
		-e   '$$p=~s%^\./%%;' \
		-e   'print "ftp://ftp.ensembl.org/$$p" if $$p=~m%(homo|human).+/pep/.+(?:known.*|novel|abinitio)\.fa.gz%' \
		-e '}' \
	>$@

fetch-sequences.log: urls
	wget -m -i $< | tee $@

hs-release-%.ls: fetch-sequences.log
	find ftp.ensembl.org/pub/release-$* -name \*.fa.gz >$@

hs-release-%.load: hs-release-%.ls
	perl -lne 'print "$$_.load"' <$< | tr \\012 \\0 | xargs -0rtn1 make

%.fa.gz.load: %.fa.gz
	R=`expr '$*' : '.*release-\([0-9]*\)'`; \
	gzip -cdq $< | load-pseq --create-origin -vv -oEnsembl-$$R-hs -V$$R -ffasta -t9606 - >$@.err 2>&1
	/bin/mv $@.err $@


cleaner::
	/bin/rm -f ls-lR.gz urls *.log
cleanest::
	/bin/rm -fr ftp.ensembl.org
