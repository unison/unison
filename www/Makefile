default:
	@echo "There is no default target"
	@echo "This makefile creates symlinks (`make links') for testing against"
	@echo "user perl libraries (esp. Unison, Unison::WWW, and Prospect2)"
	@echo "Use `make clean' to revert to using the system default perl5 libs"

links: perl5

perl5:
	mkdir $@
	ln -s ${HOME}/opt/lib/perl5/site_perl/Unison $@
	ln -s ${HOME}/opt/lib/perl5/site_perl/Prospect2 $@

clean:
	/bin/rm perl5/Unison perl5/Prospect2
	rmdir perl5
