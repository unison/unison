#!/usr/bin/env perl

use strict;
use warnings;
use CGI( -debug );
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Prospect::Options;
use Prospect::LocalClient;
use Prospect::Align;


my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

$p->ensure_required_params(qw(pseq_id params_id templates));

my $seq = $u->get_sequence_by_pseq_id( $v->{pseq_id} );
if (not defined $seq)
  { $p->die("couldn't fetch sequence for pseq_id=$v->{pseq_id}"); }

my @templates = split(/[\0,]/,$v->{templates});

my $po = $u->get_p2options_by_params_id( $v->{params_id} );
if (not defined $po)
  { $p->die("The params_id parameter ($v->params_id) is invalid."); }
$po->{templates} = \@templates;

my $pf = new Prospect::LocalClient( {options=>$po} );

my @threads = $pf->thread( $seq );
my $pa = new Prospect::Align( -debug=>0,-threads => \@threads );



print $p->render("p2threads of unison:$v->{pseq_id}",
				 $p->group('Prospect2 Threadings',
						   '<b>', $pa->get_alignment(-format=>'html'), '</b>')
				);

