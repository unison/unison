#!/usr/bin/env perl

use strict;
use warnings;
use CGI( -debug );
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
BEGIN
  {
  if (exists $ENV{SCRIPT_FILENAME})
	{ ($ENV{PWD}) = $ENV{SCRIPT_FILENAME} =~ m%^(.*/)%; }
  }
use lib $ENV{PWD}."/../perl5";
use Unison::WWW::Page;
use Unison::WWW::Table;
use Prospect2::Options;
use Prospect2::LocalClient;
use Prospect2::Align;


my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$v->{p2params_id} = 1 unless defined $v->{p2params_id};

if (not exists $v->{pseq_id})
  { $p->die("The pseq_id parameter wasn't defined ($v->{pseq_id})"); }

my $seq = $u->get_sequence_by_pseq_id( $v->{pseq_id} );
if (not defined $seq)
  { $p->die("couldn't fetch sequence for pseq_id=$v->{pseq_id}"); }

if (not exists $v->{p2params_id})
  { $p->die("The p2params_id parameter wasn't defined"); }

if (not exists $v->{templates} or not defined $v->{templates})
  { $p->die("The templates parameter wasn't defined"); }
my @templates;
@templates = split("\0",$v->{templates});


my $po = $u->get_p2options_by_p2params_id( $v->{p2params_id} );
$po->{templates} = \@templates;
my $pf = new Prospect2::LocalClient( {options=>$po} );

my @threads = $pf->thread( $seq );
my $pa = new Prospect2::Align( -debug=>0,-threads => \@threads );



print $p->render("p2threads of unison:$v->{pseq_id}",
				 $p->group('Prospect2 Threadings',
						   $pa->getAlignment(-format=>'html'))
				);

