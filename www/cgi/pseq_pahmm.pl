#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../../perl5", "$FindBin::RealBin/../../perl5-ext";

use Unison::Exceptions;
use Unison::pmodelset;
use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::WWW::utilities qw(pfam_link);
use Data::Dumper;

sub _fetch($);

my $align_elem_name = 'emb_hmm_alignment';

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

$p->ensure_required_params(qw(pseq_id));


$v->{enable_alignment} = not $p->is_public_instance();
$v->{enable_align_checked} = 0;				# BROKEN!


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


    print $p->render(
					 "HMM alignments for Unison:$v->{pseq_id}",
					 $p->best_annotation( $v->{pseq_id} ),

					 '<!-- parameters -->',
					 $p->start_form( -method => 'GET' ),
					 _javascript(),			# see below
					 $p->hidden( 'pseq_id', $v->{pseq_id} ),
					 '<br>parameters: ',
					 $p->popup_menu(
									-name    => 'params_id',
									-values  => [ map { $_->[0] } @ps ],
									-labels  => \%ps,
									-default => "$v->{params_id}",
									-onChange => 'this.form.submit()'
								   ),
					 '&nbsp;',
					 'modelsets: ',
					 $p->popup_menu(
									-name    => 'pmodelset_id',
									-values  => [ map { $_->[0] } @ms ],
									-labels  => \%ms,
									-default => "$v->{pmodelset_id}",
									-onChange => 'this.form.submit()'
								   ),
					 '&nbsp;',
					 $p->submit( -value => 'redisplay' ),
					 $p->end_form(),
					 "\n",

					 $p->group(
							   'HMM alignments',
							   Unison::WWW::Table::render( $cref, $rref ),

							   ( $v->{enable_align_checked} ?
								 (
								  '<!-- HMM profile alignment -->',
								  $p->start_form( -action => 'hmm_alignment.pl', -method => "GET" ),
								  $p->hidden( 'pseq_id',      $v->{pseq_id} ),
								  $p->hidden( 'params_id',    $v->{params_id} ),
								  $p->hidden( 'pmodelset_id', $v->{pmodelset_id} ),
								  $p->submit( -value => 'align checked' ),
								  $p->end_form(),
								 )
								 : ''
							   ),

							   ( $v->{enable_alignment}
								 ? ( 
									"<p><iframe style=\"display: none\" id=\"$align_elem_name\" width=\"100%\" height=\"300px\" scrolling=\"yes\">",
									'Sorry. I cannot display alignments because your browser does not support iframes.',
									'</iframe>'
								   )
								 : ''
							   ),

							  ),			# end group
					 "\n",

					 '<!-- sql -->',
					 $p->sql($sql)
					);
}
catch Unison::Exception with {
    $p->die(shift);
};

exit(0);



sub _javascript {
    return <<EOJS;
<script type="text/javascript" language="javascript">
function update_emb_hmm_alignment(pseq_id, params_id, pmodelset_id, acc) {
var emb_elem = document.getElementById('$align_elem_name');
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
  }


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
      ( 'name', 'descr', 'start-stop', 'mstart-mstop', 'ends', 'score', 'eval' );
    if ( $v->{enable_alignment} ) {
        unshift( @cols, 'align' );
    }
    my @rows;

    while ( my $r = $sth->fetchrow_hashref() ) {
        my @row;

        if ( $v->{enable_alignment} ) {
		  my @td;
		  if ( $v->{enable_align_checked} ) {
			push(@td, "<input type=\"checkbox\" name=\"profiles\" value=\"$r->{name}\">");
		  }
		  push(@td,
			   sprintf('<a href="javascript:update_emb_hmm_alignment(%d,%d,%d,\'%s\')">show</a>',
					   $v->{pseq_id},      $v->{params_id},
					   $v->{pmodelset_id}, $r->{name}
					  )
			  );
		  push( @row, join('&nbsp;',@td) );
        }

        push( @row,
			  pfam_link($r->{acc}, "$r->{name} ($r->{acc})"),
			  $r->{descr},
			  sprintf( "%d-%d", $r->{start},  $r->{stop} ),
			  sprintf( "%d-%d", $r->{mstart}, $r->{mstop} ),
			  $r->{ends},
			  $r->{score},
			  $r->{eval}
			);

        push( @rows, \@row );
    }

    return ( \@cols, \@rows, $sql );
}

