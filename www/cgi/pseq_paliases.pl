#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::WWW::utilities qw(alias_link text_wrap);

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$p->add_footer_lines('$Id: pseq_paliases.pl,v 1.19 2005/12/07 23:21:03 rkh Exp $ ');

my $sql = <<EOSQL;
SELECT	origin,alias,latin as species,descr
 FROM	current_annotations_v A
WHERE	pseq_id=$v->{pseq_id} AND origin_id!=origin_id('Geneseq')
EOSQL

my $ar = $u->selectall_arrayref($sql);
my @f = qw( origin alias species description );

do { $_->[1] = alias_link($_->[1],$_->[0]) } for @$ar;

# break really log "words" into fragments
do {$_->[2] = text_wrap($_->[2])} for @$ar;

print $p->render("Aliases of Unison:$v->{pseq_id}",
				 $p->best_annotation($v->{pseq_id}),
				 $p->group("Aliases of Unison:$v->{pseq_id}",
						   Unison::WWW::Table::render(\@f,$ar)),
				 $p->sql($sql)
				);
