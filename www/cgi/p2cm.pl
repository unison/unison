#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../../perl5", "$FindBin::RealBin/../../perl5-ext";

use Error qw(:try);

# uses below here might come from ../perl5 if available
use Unison::WWW;
use Unison::WWW::EmbPage;
use Unison::Jmol;

use Unison::Utilities::pfpsipred;

use Bio::Prospect::Options;
use Bio::Prospect::LocalClient;
use Bio::Prospect::Exceptions;
use Bio::Prospect::Align;

my $p = new Unison::WWW::EmbPage;
my $u = $p->{unison};
my $v = $p->Vars();
$p->ensure_required_params(qw(pseq_id params_id templates viewer));

my $seq = $u->get_sequence_by_pseq_id( $v->{pseq_id} );
if ( not defined $seq ) {
    $p->die("couldn't fetch sequence for pseq_id=$v->{pseq_id}");
}

my @templates = split( /[\0,]/, $v->{templates} );
my $template = $templates[0];

my $po = $u->get_p2options_by_params_id( $v->{params_id} );
if ( not defined $po ) {
    $p->die("The params_id parameter ($v->{params_id}) is invalid.");
}
$po->{templates} = \@templates;
$po->{"3d"} = 1;

if ( $po->{'phd'} ) {
    my $ssp =
      Unison::Utilities::pfpsipred::ssp_phd( $po->{'phd'}, $v->{pseq_id}, $u );
    if ( not defined($ssp) ) {
        $p->die("no psipred with params_id=$v->{params_id}; \n");
    }
    $po->{'phd'} = $ssp;
}
try {
    my $pf = new Bio::Prospect::LocalClient( { options => $po } );

    my @threads = $pf->thread($seq);
    my $thr     = $threads[0];

    if ( $v->{viewer} eq 'rasmol' ) {
        print(
            "Content-type: application/x-rasmol\n",
            sprintf(
                "Content-disposition: attachment; filename=%s-%s-%s.rasmol\n",
                $v->{pseq_id}, $template, $v->{params_id}
            ),
            "\n",
            $thr->output_rasmol_script(),
        );
    }
    elsif ( $v->{viewer} eq 'pymol' ) {

        $thr->qname( $v->{pseq_id} );
        my $root =
          sprintf( "%s-%s-%s", $v->{pseq_id}, $template, $v->{params_id} );
        my $filename = "$root.pml";
        print(
            "Content-type: application/x-pymol\n",
            "Content-disposition: attachment; filename=$filename\n",
            "\n",
            $thr->output_pymol_script($root),
        );
    }
    elsif ( $v->{viewer} eq 'jmol' ) {

        my $pa = new Bio::Prospect::Align( -debug => 0, -threads => \@threads );

        my $jmol = new Unison::Jmol( 600, 400 );
        $p->add_html( $jmol->script_header() );
        print $p->render(
            "Threading model for Unison:$v->{pseq_id}",
            $p->best_annotation( $v->{pseq_id} ),
            '<p>',
            $jmol->initialize_inline( $thr->output_jmol_script ),
            '<p>',
            $p->group(
                'Prospect Threading Alignment', '<b>',
                $pa->get_alignment( -format => 'html' ), '</b>'
            )
        );

    }
}
catch Bio::Prospect::Exception with {
    $p->die( "No threading result!", $_[0] );
}
catch Bio::Prospect::RuntimeError with {
    $p->die( "couldn't generate $v->{viewer} script", $@ );
};
exit(0);
