#!/usr/bin/env perl

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::WWW::Utils qw(alias_link);

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

$p->ensure_required_params( qw( pseq_id ) );


my $sql = qq/select O.origin,AO.alias,AO.descr from pseqalias SA
			join paliasorigin AO on AO.palias_id=SA.palias_id
			join porigin O on O.porigin_id=AO.porigin_id
			where SA.pseq_id=$v->{pseq_id} and SA.iscurrent=true and O.ann_pref<=10000 
			order by O.ann_pref/;
my $ar = $u->selectall_arrayref($sql);
do { $_->[1] = alias_link($_->[1],$_->[0]) } for @$ar;
my @f = qw( origin alias description );

my $seq = $u->get_sequence_by_pseq_id($v->{pseq_id});
$seq =~ s/.{60}/$&\n/g;

print $p->render("Summary of Unison:$v->{pseq_id}",

				 $p->group("Sequence",
						   '<pre>', 
						   '&gt;', $u->best_alias($v->{pseq_id}), "\n",
						   $seq,
						   '</pre>' ),

				 $p->group("Aliases",
						   'These are the aliases from the most reliable sources only; see also ',
						   '<a href="pseq_paliases.pl?pseq_id=', $v->{pseq_id}, '">other aliases</a><p>',
						   Unison::WWW::Table::render(\@f,$ar)),


				 $p->group("Features",
						   "<img src=\"graphic_features.sh?pseq_id=$v->{pseq_id}\">"),

				 $p->sql($sql)
				);
