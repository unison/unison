UHOME:=/home/rkh/csb-db/unison
export PATH:=${UHOME}/sbin:${UHOME}/bin:${UHOME}/misc:/apps/compbio/i686-linux-2.4/bin:/usr/bin:/bin
export PGUSER:=loader
export PGDATABASE:=csb-dev
export PERL5LIB:=${HOME}/csb-db/unison/perl


#$(warning 'UHOME=${UHOME}' )
#$(warning 'PGUSER=${PGUSER}' )
#$(warning 'PGDATABASE=${PGDATABASE}' )
#$(warning 'PERL5LIB=${PERL5LIB}' )
ifndef PGPASSWORD
$(warning "PGPASSWORD isn't set" )
endif




.PHONY: clean cleaner cleanest
clean:
	/bin/rm -f *~ *.bak
