#!/usr/bin/env perl

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::WWW::utils qw(alias_link text_wrap);

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my $sql = qq/select O.origin,AO.alias,AO.descr from pseqalias SA
			join paliasorigin AO on AO.palias_id=SA.palias_id
			join porigin O on O.porigin_id=AO.porigin_id
			where SA.pseq_id=$v->{pseq_id} and SA.iscurrent=true and AO.porigin_id!=10031
			order by O.ann_pref/;
my $ar = $u->selectall_arrayref($sql);
my @f = qw( origin alias description );

do { $_->[1] = alias_link($_->[1],$_->[0]) } for @$ar;

# break really log "words" into fragments
do {$_->[2] = text_wrap($_->[2])} for @$ar;

print $p->render("Aliases of Unison:$v->{pseq_id}",
				 $p->best_annotation($v->{pseq_id}),
				 $p->group("Aliases of Unison:$v->{pseq_id}",
						   Unison::WWW::Table::render(\@f,$ar)),
				 $p->sql($sql)
				);
