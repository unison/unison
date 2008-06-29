#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../../perl5", "$FindBin::RealBin/../../perl5-ext";

use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my $sql = 'select M.acc as "model",A.start,A.stop,A.score,A.eval
		   from papssm A join pmpssm M on A.pmodel_id=M.pmodel_id
		   where pseq_id=' . $v->{pseq_id} . ' order by eval';
my $ar = edit_rows( $u->selectall_arrayref($sql) );
my @f = ( 'model', 'start-stop', 'score', 'eval' );

print $p->render(
    "PSSM Alignments to Unison:$v->{pseq_id}",
    $p->best_annotation( $v->{pseq_id} ),
    $p->group( "PSSM/SBP alignments", Unison::WWW::Table::render( \@f, $ar ) ),
    $p->sql($sql)
);

sub edit_rows {
    my $ar = shift;
    foreach my $r (@$ar) {
        splice( @$r, 1, 2, sprintf( "%d-%d", @$r[ 1 .. 2 ] ) );
    }
    return $ar;
}
