#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::WWW::utilities qw(alias_link pseq_summary_link);

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$p->add_footer_lines('$Id: pseq_mint.pl,v 1.2 2004/06/25 00:20:14 rkh Exp $ ');

my $sql = qq/select pseq_id_b, sprot_b, best_annotation(pseq_id_b), pmid, interaction_detection_method
      from v_mint where pseq_id_a=$v->{pseq_id}/;

my $ar = $u->selectall_arrayref($sql);
my @f = ( 'Sequence', 'Swiss-Prot', 'Best annotation', 'PubMed', 'Interaction detection method', 'Link' );

my $sprot_a = $u->selectrow_array
  ("select alias from palias where porigin_id=porigin_id('Swiss-Prot') and pseq_id=$v->{pseq_id} and alias~'^[A-Z][0-9]+\$'");

# work right-to-left
do { $_->[5]= alias_link($_->[1],'Mint') } for @$ar;
do { $_->[3] = alias_link($_->[3],'Pubmed') } for @$ar;
do { $_->[1] = alias_link($_->[1],'Swiss-Prot') } for @$ar;
do { $_->[0] = pseq_summary_link($_->[0],"Unison:$_->[0]") } for @$ar;


print $p->render("Mint data: $v->{pseq_id}",
				 $p->best_annotation($v->{pseq_id}),

				 '<p>',
				 ($sprot_a ? "Go to MINT with Unison:$v->{pseq_id}: ". alias_link($sprot_a,'Mint') 
				  : 'No interactions'),

				 '<p>',
				 $p->group("Unison:$v->{pseq_id} interacts with",
						   Unison::WWW::Table::render(\@f,$ar)),
				 $p->sql($sql)
				);

