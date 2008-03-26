#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq",
  "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::WWW::utilities qw(alias_link text_wrap);
use Unison::SQL;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my $sql = new Unison::SQL;
$sql->columns(qw(origin alias latin descr))->tables('current_annotations_v')
  ->where("pseq_id=$v->{pseq_id}");
if ( not $p->is_public() ) {
    $sql->where("origin_id!=origin_id('Geneseq')");
}

my $ar = $u->selectall_arrayref("$sql");
my @f  = qw( origin alias latin description );

foreach my $row (@$ar) {
  $row->[1] = alias_link( $row->[1], $row->[0] );

  if ($row->[0] eq 'IPI') { #length($row->[3]) > 30) {
	$row->[3] =~ s/([;|])/$1 /g;
  }
}

# break really log "words" into fragments
do { $_->[2] = text_wrap( $_->[2] ) }
  for @$ar;

print $p->render(
    "Aliases of Unison:$v->{pseq_id}",
    $p->best_annotation( $v->{pseq_id} ),
    $p->group(
        "Aliases of Unison:$v->{pseq_id}",
        Unison::WWW::Table::render( \@f, $ar )
    ),
    $p->sql($sql)
);
