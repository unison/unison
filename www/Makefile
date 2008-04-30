.SUFFIXES:
.PHONY: FORCE

default:
	@echo "There is no default target"
	@echo "This makefile creates symlinks (`make links') for testing against"
	@echo "user perl libraries (esp. Unison, Unison::WWW, and Prospect2)"
	@echo "Use `make clean' to revert to using the system default perl5 libs"

#renav -- update the navigation banner in the web pages
renav: FORCE
	./bin/insert-quicklink-menu.pl credits.html index.html license.html more.html shots.html topnav.html

#www-prep -- prepare a web directory for use
#This is only needed when unison/www is the document root.
#If not, then Unison will expect to have a tmp dir elsewhere
www-prep:
	mkdir -p tmp ../log; chmod 777 tmp ../log

#push-offline -- push the offline page to my Reece's personal website
#That page is used only when unison is down for some reason.
push-offline: FORCE
	rsync -Rav offline.html styles/unison.css av hn:www/unison/

