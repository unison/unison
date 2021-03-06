#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my @psets = @{
    $u->selectall_arrayref(
        "select pset_id,name from pset where pset_id>=1000 order by pset_id")
  };
my %psets = map { $_->[0] => "$_->[1] (set $_->[0])" } @psets;

print $p->render(
    "Browse Sets",
    $p->start_form( -method => 'GET' ),
    "show sequences in set ",

    $p->popup_menu(
        -name    => 'pset_id',
        -values  => [ map { $_->[0] } @psets ],
        -labels  => \%psets,
        -default => $v->{pset_id} || undef
    ),
    $p->submit( -value => 'submit' ),
    $p->end_form(),
    "\n",

    "<hr>\n",
    do_search($p)
);

sub do_search {
    my $p = shift;
    my $v = $p->Vars();
    return '' unless ( defined $v->{pset_id} and $v->{pset_id} ne '' );

    my $N = $u->selectrow_array(
        "select count(*) from pseqset where pset_id=$v->{pset_id}");

    if ( $N >= 1000 ) {
        return (
            $p->group(
                $psets{ $v->{pset_id} },
                "There are $N sequences in this set. Trust us, you
					  don't want to view that many in a web page."
            ),
        );
    }

    my $sql =
"select pseq_id,best_annotation(pseq_id) from pseqset where pset_id=$v->{pset_id}";
    my $ar = $u->selectall_arrayref($sql);

    foreach my $row (@$ar) {
        $row->[0] =
          "<a href=\"pseq_summary.pl?pseq_id=$row->[0]\">$row->[0]</a>";
    }

    my @f = qw( pseq_id description );
    return (
        $p->group(
            "$psets{$v->{pset_id}}: $N sequences",
            Unison::WWW::Table::render( \@f, $ar )
        ),
        $p->sql($sql)
    );
}
