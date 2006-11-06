PATH:=/usr/bin:/bin

.PHONY: install
install: Error.pm

Error.pm:
	wget -O$@.tmp -nd http://search.cpan.org/src/SHLOMIF/Error-0.17008/lib/Error.pm
	mv $@.tmp $@

CBT:
	cvs -d :ext:csb:/srv/cvs export -rHEAD CBT

test:
	PERL5LIB=. perl -MUnison </dev/null
