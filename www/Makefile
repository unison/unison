default:
	@echo "There is no default target"
	@echo "This makefile creates symlinks (`make links') for testing against"
	@echo "user perl libraries (esp. Unison, Unison::WWW, and Prospect2)"
	@echo "Use `make clean' to revert to using the system default perl5 libs"

perl5/site_perl:
	cvs

clean:
	/bin/rm perl5/Unison perl5/Prospect2
	rmdir perl5
