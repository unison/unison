#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../../perl5", "$FindBin::RealBin/../../perl5-ext";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

$v->{pct_ident}    = 98 unless exists $v->{pct_ident};
$v->{pct_coverage} = 98 unless exists $v->{pct_coverage};
$v->{pseq_id} = $p->_infer_pseq_id(); # internal function called. Shame on me.

print $p->render(
    "Patents 'near' Unison:$v->{pseq_id}",
    $p->best_annotation( $v->{pseq_id} ),

    $p->start_form( -method => 'GET' ),

    #								-action => $p->make_url()),

    "show patents within ",
    $p->popup_menu(
				   -name    => 'pct_ident',
				   -values  => [qw(100 99 98 97 96 95 90)],
				   -default => $v->{pct_ident},
				   -onChange => 'this.form.submit()'
    ),
    " % identity and ",
    $p->popup_menu(
        -name    => 'pct_coverage',
        -values  => [qw(100 99 98 97 96 95 90)],
        -default => $v->{pct_coverage},
				   -onChange => 'this.form.submit()'
    ),
    " % coverage of Unison:$v->{pseq_id}",
    $p->hidden(
        -name  => 'pseq_id',
        -value => $v->{pseq_id}
    ),

    $p->submit( -value => 'submit' ),
    $p->end_form(),
    "\n",

    do_search($p)
);

sub do_search {
    my $p = shift;
    my $v = $p->Vars();
    return '' unless ( defined $v->{pseq_id} and $v->{pseq_id} ne '' );

	my $patents_view = $p->is_public_instance ? 'patents_pataa_v' : 'patents_geneseq_v';

    my $sql = <<EOSQL;
SELECT t_pseq_id,len,pct_coverage,pct_ident,
		origin_alias_fmt(origin,alias),species,patent_date,patent_authority,descr
    FROM nearby_sequences_unsorted_v B
    JOIN $patents_view P ON B.t_pseq_id=P.pseq_id
    WHERE B.q_pseq_id=$v->{pseq_id} 
      AND pct_ident>=$v->{pct_ident}
      AND pct_coverage>=$v->{pct_coverage}
ORDER BY pct_coverage desc,pct_ident desc,pseq_id,patent_date,patent_authority,origin = 'pataa', alias
EOSQL

    my $ar = $u->selectall_arrayref($sql);
	foreach my $rr (@$ar) {
	  $rr->[2] = sprintf("%d",$rr->[2]);
	  $rr->[3] = sprintf("%d",$rr->[3]);
	}

    my @f = qw( pseq_id len %COV %IDE alias species date authority description );
    return (
        "<hr>\n",
        $p->group( "Patent Results", Unison::WWW::Table::render( \@f, $ar ) ),
        $p->sql($sql)
    );
}
