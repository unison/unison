#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
BEGIN
  {
  if (exists $ENV{SCRIPT_FILENAME})
	{ ($ENV{PWD}) = $ENV{SCRIPT_FILENAME} =~ m%^(.*/)%; }
  }
use lib $ENV{PWD}."/../perl5";
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

print $p->render("Unison:$v->{pseq_id} Features Overview",
				 $p->group("Unison:$v->{pseq_id} Features",
						   '<center>',
						   "<img align=\"center\" src=\"graphic_features.sh?pseq_id=$v->{pseq_id}\">",
						   '</center>',
						  ),
				);
