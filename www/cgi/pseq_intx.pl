#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::WWW::utilities qw(alias_link text_wrap);

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my $sql = qq/select sprot_a, organism_a, sprot_b, organism_b, pmid, interaction_detection_method
      from sulin.v_mint
      where pseq_id=$v->{pseq_id}/;

my $ar = $u->selectall_arrayref($sql);
my @f = ( 'Swiss-Prot A', 'Organsim A', 'Swiss-Prot B', 'Organism B', 'PubMed', 'Interaction detection method' );

do { $_->[0] = alias_link($_->[0],'Swiss-Prot') } for @$ar;
do { $_->[2] = alias_link($_->[2],'Swiss-Prot') } for @$ar;
do { $_->[4] = alias_link($_->[4],'Pubmed') } for @$ar;

# break really log "words" into fragments
#do {$_->[2] = text_wrap($_->[2])} for @$ar;

print $p->render("Mint data: $v->{pseq_id}",
				 $p->best_annotation($v->{pseq_id}),
				 $p->group("Mint data: $v->{pseq_id}",
						   Unison::WWW::Table::render(\@f,$ar)),
				 $p->sql($sql)
				);

