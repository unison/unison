#!/usr/bin/env perl

use strict;
use warnings;
use CGI( -debug );
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

my $sql = qq/select * from meta/;
my $ar = $u->selectall_arrayref($sql);
my @f = qw( key value );

print $p->render("Unison contents and Meta Information",
				 $p->group("Meta",
						   Unison::WWW::Table::render(\@f,$ar)),
				 $p->sql($sql)
				);
