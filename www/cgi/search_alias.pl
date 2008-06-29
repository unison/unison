#!/usr/bin/env perl
# search_alias -- search Unison by alias

use warnings;
use strict;

use FindBin;
use lib "$FindBin::RealBin/../../perl5", "$FindBin::RealBin/../../perl5-ext";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page();
my $u = $p->{unison};
my $v = $p->Vars();

print $p->render(
    "Search by Alias" . ( defined $v->{alias} ? ": $v->{alias}" : '' ),

    $p->tip("use % for wildcard (but it's slower)"),
    $p->start_form(
        -method => 'GET',
        -action => $p->make_url()
    ),
    "alias: ",
    $p->textfield(
        -name      => 'alias',
        -default   => $v->{alias},
        -size      => 50,
        -maxlength => 50
    ),
    $p->submit( -value => 'submit' ),
    '<br><i>e.g.,</i>, <code>NP_000506.2</code>, or <code>^TNFA</code>',
    $p->end_form(),
    "\n",

    ( defined $v->{alias} ? do_search( $v->{alias} ) : '' )
);

sub do_search {
    my $q          = shift;
    my $max_seqs   = 1000;
    my (@pseq_ids) = $u->get_pseq_id_from_alias($q);

    if ( $#pseq_ids == -1 ) {
        return ('<b>No results returned</b>'
              . '<br>NOTE: Short regexp queries are silently ignored.' );
    }

    if ( $#pseq_ids >= $max_seqs ) {
        return ("<b>Too many results returned ("
              . ( $#pseq_ids + 1 )
              . "); please narrow your query (max is $max_seqs)</b>" );
    }

    my $sth = $u->prepare('select best_annotation(?)');
    my @ar = map { [ $_, $u->selectrow_array( $sth, undef, $_ ) ] } @pseq_ids;
    my @fields = ( 'pseq_id', 'best annotation [origin:alias (description)]' );
    my $ar     = \@ar;
    for ( my $i = 0 ; $i <= $#$ar ; $i++ ) {
        $ar->[$i][0] = sprintf( '<a href="pseq_summary.pl?pseq_id=%d">%d</a>',
            $ar->[$i][0], $ar->[$i][0] );
    }

    return $p->group(
        sprintf( "%d results for %s", $#$ar + 1, $q ),
        Unison::WWW::Table::render( \@fields, $ar )
    );
}
