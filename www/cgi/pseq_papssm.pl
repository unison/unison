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
$p->add_footer_lines('$Id: pseq_summary.pl,v 1.31 2005/06/15 03:44:55 rkh Exp $ ');

my $sql = 'select M.acc as "model",A.start,A.stop,A.score,A.eval
		   from papssm A join pmpssm M on A.pmodel_id=M.pmodel_id
		   where pseq_id='.$v->{pseq_id}.' order by eval';
my $ar = edit_rows( $u->selectall_arrayref($sql) );
my @f = ('model', 'start-stop', 'score', 'eval');

print $p->render("PSSM/SBP alignments to Unison:$v->{pseq_id}",
				 $p->best_annotation($v->{pseq_id}),
				 $p->group("PSSM/SBP alignments",
						   Unison::WWW::Table::render(\@f,$ar)),
				 $p->sql($sql)
				);

sub edit_rows {
  my $ar = shift;
  foreach my $r (@$ar) {
	splice( @$r,1,2, sprintf("%d-%d",@$r[1..2]) );
  }
  return $ar;
  }
