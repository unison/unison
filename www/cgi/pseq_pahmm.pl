#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::Exceptions;
use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Data::Dumper;

sub _fetch($);

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

$p->ensure_required_params(qw(pseq_id));
$p->add_footer_lines('$Id: pseq_pahmm.pl,v 1.16 2005/09/16 04:46:20 rkh Exp $ ');


try {
  my @ps = $u->get_params_info_by_pftype('hmm');
  my %ps = map { $_->[0] => "$_->[1] (params $_->[0])" } @ps;

  if (not defined $v->{params_id}) {
	$v->{params_id} = 
	  $u->get_current_params_id_by_pftype($v->{pseq_id},'hmm')
		|| $ps[0]->[0];
  }

  my ($cref,$rref,$sql) = _fetch($p);

  print $p->render (
					"HMM alignments for Unison:$v->{pseq_id}",
					$p->best_annotation($v->{pseq_id}),

					'<!-- parameters -->',
					$p->start_form(-method=>'GET'),
					$p->hidden('pseq_id',$v->{pseq_id}),
					'<br>parameters: ', $p->popup_menu(-name => 'params_id',
													   -values => [map {$_->[0]} @ps],
													   -labels => \%ps,
													   -default => "$v->{params_id}"),
					$p->submit(-value=>'redisplay'),
					$p->end_form(), "\n",

					'<!-- HMM profile alignment -->',
					$p->start_form(-action=>'hmm_alignment.pl', -method=>"GET"),
					$p->hidden('pseq_id',$v->{pseq_id}),
					$p->hidden('params_id',$v->{params_id}),

					( $p->is_public() ? '' : ('<p>', $p->submit(-value=>'align checked')) ),

					$p->group("HMM alignments",
							  Unison::WWW::Table::render($cref,$rref)),

					'<!-- sql -->',
					$p->sql($sql)
				   );
} catch Unison::Exception with {
  $p->die(shift);
};

exit(0);



sub _fetch($) {
  my $p = shift;

  my $sql = <<EOSQL;
  SELECT start,stop,mstart,mstop,ends,score,eval,name,acc,descr
    FROM pahmm_v
   WHERE pseq_id=$v->{pseq_id} and params_id=$v->{params_id}
ORDER BY eval
EOSQL
  my $sth = $u->prepare($sql);
  my $ar = $sth->execute();

  my @cols = ('name', 'start-stop', 'mstart-mstop', 'ends', 'score', 'eval');
  if ( not $p->is_public_instance() ) {
	unshift(@cols, 'aln?');
  }
  my @rows;

  while ( my $r = $sth->fetchrow_hashref() ) {
	my $name = sprintf('<a tooltip="%s" href="http://pfam.wustl.edu/cgi-bin/getdesc?name=%s">%s (%s)</a>',
					   $r->{descr}, $r->{name}, $r->{name}, $r->{acc});
	my @row;

	if ( not $p->is_public_instance() ) {
	  push(@row, sprintf('<input type="checkbox" name="profiles" value="%s">', $r->{name}))
	}

	push(@row,
		 $name,
		 sprintf("%d-%d", $r->{start}, $r->{stop}),
		 sprintf("%d-%d", $r->{mstart}, $r->{mstop}),
		 $r->{ends},
		 $r->{score},
		 $r->{eval}
		);

	push(@rows, \@row);
  }

  return( \@cols, \@rows, $sql );
}






