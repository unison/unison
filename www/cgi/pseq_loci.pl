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

my $sql = qq/select pstart,pstop,genome.name,chr,gstart,gstop,ident,eval
			from plocus natural join genome where plocus.pseq_id=$v->{pseq_id}/;
my $ar = $u->selectall_arrayref($sql);
my @f = ('pstart', 'pstop', 'genome name', 'chr', 'gstart', 'gstop', 'ident', 'eval' );

print $p->render("Loci of Unison:$v->{pseq_id}",
				 $p->group("Loci",
						   Unison::WWW::Table::render(\@f,$ar)),
				 $p->sql($sql)
				);
