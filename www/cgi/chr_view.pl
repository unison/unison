#!/usr/bin/env perl

use strict;
use warnings;
use Error qw(:try);
use CGI ( -debug );
use CGI::Carp qw(fatalsToBrowser);
use Bio::Structure::IO;

# use's below here might come from ../perl5 if available
BEGIN
  {
  if (exists $ENV{SCRIPT_FILENAME})
	{ ($ENV{PWD}) = $ENV{SCRIPT_FILENAME} =~ m%^(.*/)%; }
  }
use lib $ENV{PWD}."/../perl5";
use Unison::WWW::Page;


my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$p->ensure_required_params(qw(chr gstart gstop));


printf("Content-type: application/geode\n"
	   . "Content-Disposition: filename=\"test.geode\"\n"
	   . "\n"
	   . "protocol=by_chr_pos,chr_name=%s,chr_start=%d,chr_end=%d\n\n",
	   $v->{chr}, $v->{gstart}, $v->{gstop}
	  );

exit(0);
