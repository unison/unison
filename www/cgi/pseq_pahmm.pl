#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq",
  "$FindBin::Bin/../../perl5";

use Unison::Exceptions;
use Unison::pmodelset;
use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Data::Dumper;

sub _fetch($);

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

$p->ensure_required_params(qw(pseq_id));
$p->add_footer_lines(
    '$Id: pseq_pahmm.pl,v 1.21 2007/01/09 17:43:02 mukhyala Exp $ ');

try {
    my @ps = $u->get_params_info_by_pftype('hmm');
    my %ps = map { $_->[0] => "$_->[1] (params $_->[0])" } @ps;

    my @ms = $u->get_pmodelsets_hmm();
    my %ms = map { $_->[0] => "$_->[1] (modelset $_->[0])" } @ms;

    if ( not defined $v->{params_id} ) {
        $v->{params_id} = $u->preferred_params_id_by_pftype('HMM')
          || $ps[0]->[0];
    }

    if ( not defined $v->{pmodelset_id} ) {
        $v->{pmodelset_id} = $u->preferred_pmodelset_id_by_pftype('HMM')
          || $ps[0]->[0];
    }

    my ( $cref, $rref, $sql ) = _fetch($p);

    my $js = <<EOJS;
<script type="text/javascript" language="javascript">
function update_emb_hmm_alignment(pseq_id, params_id, pmodelset_id, acc) {
var emb_elem = document.getElementById('emb_hmm_alignment');
if (emb_elem) {
  var emb_url = 'emb_hmm_alignment.pl?';
  emb_url += 'pseq_id='+pseq_id;
  emb_url += ';params_id='+params_id;
  emb_url += ';pmodelset_id='+pmodelset_id;
  emb_url += ';profiles='+acc;
  emb_elem.setAttribute('src', emb_url);
  emb_elem.style.display = 'block';
  }
}
</script>
EOJS

    print $p->render(
        "HMM alignments for Unison:$v->{pseq_id}",
        $p->best_annotation( $v->{pseq_id} ),

        '<!-- parameters -->',
        $p->start_form( -method => 'GET' ),
        $js,
        $p->hidden( 'pseq_id', $v->{pseq_id} ),
        '<br>parameters: ',
        $p->popup_menu(
            -name    => 'params_id',
            -values  => [ map { $_->[0] } @ps ],
            -labels  => \%ps,
            -default => "$v->{params_id}"
        ),
        '&nbsp;',
        'modelsets: ',
        $p->popup_menu(
            -name    => 'pmodelset_id',
            -values  => [ map { $_->[0] } @ms ],
            -labels  => \%ms,
            -default => "$v->{pmodelset_id}"
        ),
        '&nbsp;',
        $p->submit( -value => 'redisplay' ),
        $p->end_form(),
        "\n",

        '<!-- HMM profile alignment -->',
        $p->start_form( -action => 'hmm_alignment.pl', -method => "GET" ),
        $p->hidden( 'pseq_id',      $v->{pseq_id} ),
        $p->hidden( 'params_id',    $v->{params_id} ),
        $p->hidden( 'pmodelset_id', $v->{pmodelset_id} ),

        $p->group(
            "HMM alignments",
            Unison::WWW::Table::render( $cref, $rref )
        ),

        (
            $p->is_public()
            ? ''
            : (
                '<p>',
                $p->submit( -value => 'align checked' ),
'<p><iframe style="display: none" id="emb_hmm_alignment" width="100%" height="300px" scrolling="yes">',
'Sorry. I cannot display alignments because your browser does not support iframes.',
                '</iframe>'
            )
        ),

        '<!-- sql -->',
        $p->sql($sql)
    );
}
catch Unison::Exception with {
    $p->die(shift);
};

exit(0);

sub _fetch($) {
    my $p = shift;

    my $sql = <<EOSQL;
  SELECT start,stop,mstart,mstop,ends,score,eval,name,acc,descr
    FROM pahmm_v p
    JOIN pmsm_pmhmm m on p.pmodel_id=m.pmodel_id
   WHERE pseq_id=$v->{pseq_id} and params_id=$v->{params_id} and m.pmodelset_id=$v->{pmodelset_id}
ORDER BY eval
EOSQL
    my $sth = $u->prepare($sql);
    my $ar  = $sth->execute();

    my @cols =
      ( 'name', 'start-stop', 'mstart-mstop', 'ends', 'score', 'eval' );
    if ( not $p->is_public_instance() ) {
        unshift( @cols, 'align' );
    }
    my @rows;

    while ( my $r = $sth->fetchrow_hashref() ) {
        my $name =
          sprintf(
'<a tooltip="%s" href="http://pfam.janelia.org/family?id=%s">%s (%s)</a>',
            $r->{descr}, $r->{name}, $r->{name}, $r->{acc} );
        my @row;

        if ( not $p->is_public_instance() ) {
            my $ckbox =
"<input type=\"checkbox\" name=\"profiles\" value=\"$r->{name}\">";
            my $aln = sprintf(
'<a href="javascript:update_emb_hmm_alignment(%d,%d,%d,\'%s\')">show</a>',
                $v->{pseq_id},      $v->{params_id},
                $v->{pmodelset_id}, $r->{name}
            );
            push( @row, "$ckbox &nbsp; &nbsp; $aln" );
        }

        push( @row,
            $name,
            sprintf( "%d-%d", $r->{start},  $r->{stop} ),
            sprintf( "%d-%d", $r->{mstart}, $r->{mstop} ),
            $r->{ends},
            $r->{score},
            $r->{eval} );

        push( @rows, \@row );
    }

    return ( \@cols, \@rows, $sql );
}

