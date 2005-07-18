default:
	@echo "There is no default target"
	@echo "This makefile creates symlinks (`make links') for testing against"
	@echo "user perl libraries (esp. Unison, Unison::WWW, and Prospect2)"
	@echo "Use `make clean' to revert to using the system default perl5 libs"

# eventually:
# perl5-prereq target
# packaging targets (akin to md5, pgp signing, etc for unison)

clean:
	/bin/rm perl5/Unison perl5/Prospect2
	rmdir perl5
