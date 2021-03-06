#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Data::Dumper;
use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::WWW::utilities qw(pseq_annotations_link);

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
splice( @$_, 0, 2, pseq_annotations_link( $_->[0], undef, $_->[1] ) ) for @$ar;

my @f = (
    'target',               "Unison:$v->{pseq_id}<br>qstart-qstop",
    'target<br>stop-start', 'len',
    'ident',                'sim',
    'gaps',                 'eval',
    'identity (%)',         'HSP coverage (%)',
    'coverage (%)'
);

print $p->render(
    "Sequence similarity for Unison:$v->{pseq_id}",
    $p->best_annotation( $v->{pseq_id} ),
    $p->tip('hover over entries in the target column to see annotations'),
    $p->group(
        "Sequences similar to Unison:$v->{pseq_id}",
        Unison::WWW::Table::render( \@f, $ar )
    ),
    $p->sql($sql)
);
