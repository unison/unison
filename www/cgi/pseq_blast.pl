#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq",
  "$FindBin::Bin/../../perl5";

use Data::Dumper;
use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my $sql = <<EOSQL;
SELECT t_pseq_id,best_annotation(t_pseq_id),
  q_start||'-'||q_stop,t_start||'-'||t_stop,
  len,ident,sim,gaps,eval,pct_ident::int,
  pct_hsp_coverage::int,pct_coverage::int
FROM papseq_v
WHERE q_pseq_id=$v->{pseq_id}
ORDER BY pct_ident desc,len desc,eval
EOSQL

my $ar = $u->selectall_arrayref($sql);
splice( @$_, 0, 2, mk_palias_link( $_->[0], $_->[1] ) ) for @$ar;

my @f = (
    'target',               "Unison:$v->{pseq_id}<br>qstart-qstop",
    'target<br>stop-start', 'len',
    'ident',                'sim',
    'gaps',                 'eval',
    'identity (%)',         'HSP coverage (%)',
    'coverage (%)'
);

print $p->render(
    "Near-identity BLASTs for Unison:$v->{pseq_id}",
    $p->best_annotation( $v->{pseq_id} ),
    $p->tip('hover over entries in the target column to see annotations'),
    $p->group(
        "BLASTS Unison:$v->{pseq_id}",
        Unison::WWW::Table::render( \@f, $ar )
    ),
    $p->sql($sql)
);

sub mk_palias_link {

#  return( "<a href=\"pseq_paliases.pl?pseq_id=$_[0]\" tooltip='$_[1]'>$_[0]</a>" );
    return (
        sprintf(
            "<a href=\"pseq_paliases.pl?pseq_id=$_[0]\" tooltip='%s'>$_[0]</a>",
            ( defined $_[1] ? $_[1] : '<no annotation>' ) )
    );
}
