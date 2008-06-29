#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../../perl5", "$FindBin::RealBin/../../perl5-ext";

use CGI( -debug );
use CGI::Carp qw(fatalsToBrowser);

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::Utilities::pfpsipred;
use Unison::Exceptions;

use Bio::Prospect::Options;
use Bio::Prospect::LocalClient;
use Bio::Prospect::Align;
use Bio::Prospect::Exceptions;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

$p->ensure_required_params(qw(pseq_id params_id templates));

my $seq = $u->get_sequence_by_pseq_id( $v->{pseq_id} );
if ( not defined $seq ) {
    $p->die("couldn't fetch sequence for pseq_id=$v->{pseq_id}");
}

my @templates = split( /[\0,]/, $v->{templates} );

my $po = $u->get_p2options_by_params_id( $v->{params_id} );
if ( not defined $po ) {
    $p->die("The params_id parameter ($v->params_id) is invalid.");
}
$po->{templates} = \@templates;

if ( $po->{'phd'} ) {
    my $ssp =
      Unison::Utilities::pfpsipred::ssp_phd( $po->{'phd'}, $v->{pseq_id}, $u );
    if ( not defined($ssp) ) {
        $p->die("no psipred with params_id=$v->{params_id}; \n");
    }
    $po->{'phd'} = $ssp;
}

my $pf = new Bio::Prospect::LocalClient( { options => $po } );

try {
    my @threads = $pf->thread($seq);
    my $pa = new Bio::Prospect::Align( -debug => 0, -threads => \@threads );
    print $p->render(
        "Prospect Threading for Unison:$v->{pseq_id}",
        $p->group(
            'Prospect Threadings', '<b>',
            $pa->get_alignment( -format => 'html' ), '</b>'
        )
    );
}
catch Bio::Prospect::Exception with {
    $p->die( $_[0] );
};
