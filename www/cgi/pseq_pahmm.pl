#!/usr/bin/env perl

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my $sql = 'select M.name as "model",A.start,A.stop,A.mstart,A.mstop,M.len,A.score,A.eval,M.acc
		   from pahmm A join pmhmm M on A.pmodel_id=M.pmodel_id
		   where pseq_id='.$v->{pseq_id}.' order by eval';
my $ar = edit_rows( $u->selectall_arrayref($sql) );
my @f = ('name', 'start-stop', 'mstart-mstop', '[]', 'score', 'eval');

print $p->render("HMM alignments to Unison:$v->{pseq_id}",
				 $p->group("HMM alignments",
						   Unison::WWW::Table::render(\@f,$ar)),
				 $p->sql($sql)
				);

sub edit_rows {
  my $ar = shift;
  foreach my $r (@$ar) {
	$r->[0] = sprintf('<a href="http://pfam.wustl.edu/cgi-bin/getdesc?acc=%s">%s</a>',
					   $r->[$#$r], $r->[0]);
	$r->[5] = ($r->[3]==1?'[':'.') . ($r->[4]==$r->[5]?']':'.');
	splice( @$r,3,2, sprintf("%d-%d",@$r[3..4]) );
	splice( @$r,1,2, sprintf("%d-%d",@$r[1..2]) );
	pop(@$r);
  }
  return $ar;
  }
