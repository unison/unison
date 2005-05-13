#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my @ps = $u->get_params_info_by_pftype('hmm');
my %ps = map { $_->[0] => "$_->[1] (set $_->[0])" } @ps;

$v->{params_id} = $ps[0]->[0] unless defined $v->{params_id};
$p->ensure_required_params(qw(pseq_id params_id));
$p->add_footer_lines('$Id: pseq_pahmm.pl,v 1.10.2.1 2005/05/13 18:48:41 rkh Exp $ ');

my $sql = sprintf(<<EOSQL,$v->{pseq_id},$v->{params_id});
select M.name as "model",A.start,A.stop,A.mstart,A.mstop,M.len,A.score,A.eval,M.acc
  from pahmm A join pmhmm M on A.pmodel_id=M.pmodel_id
  where pseq_id=%d and params_id=%d order by eval
EOSQL
my $ar = edit_rows( $u->selectall_arrayref($sql,undef) );
my @f = ('aln?', 'name', 'start-stop', 'mstart-mstop', '[]', 'score', 'eval');



print $p->render
  (
   "HMM alignments to Unison:$v->{pseq_id}",
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

   '<!-- results -->',
   (($#$ar==-1 and $v->{params_id}==15)
    ? $p->warn("No alignments... consider selecting the Pfam_fs 12.0 parameter set and clicking redisplay.")
    : ''),

   '<!-- HMM profile alignment -->',
   $p->start_form(-action=>'hmm_alignment.pl'),
   $p->hidden('pseq_id',$v->{pseq_id}),
   $p->hidden('params_id',$v->{params_id}),
   '<p>', $p->submit(-value=>'align checked'),

   $p->group("HMM alignments",
	     Unison::WWW::Table::render(\@f,$ar)),

   '<!-- sql -->',
   $p->sql($sql)
  );


sub edit_rows {
  my $ar = shift;
  foreach my $r (@$ar) {
    my $rnew; #will replace r with an extra aln checkbox column at the start
    # build checkbox for alignment
    push @$rnew, "<input type=\"checkbox\" name=\"profiles\" "
      . "value=\"$r->[0]\">";
	#my ($acc) = $r->[$#$r] =~ m/^(PF\d+)/;
	#$r->[0] = sprintf('<a href="http://pfam.wustl.edu/cgi-bin/getdesc?acc=%s">%s</a>',
	#				   $acc, $r->[0]);
	$r->[0] = sprintf('<a href="http://pfam.wustl.edu/cgi-bin/getdesc?name=%s">%s</a>',
					   $r->[0], $r->[0]);
	$r->[5] = ($r->[3]==1?'[':'.') . ($r->[4]==$r->[5]?']':'.');
	splice( @$r,3,2, sprintf("%d-%d",@$r[3..4]) );
	splice( @$r,1,2, sprintf("%d-%d",@$r[1..2]) );
	pop(@$r);

    push @$rnew, @$r;
    $r = $rnew;
  }
  return $ar;
}
