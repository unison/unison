#!/usr/bin/env perl

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::Exceptions;


my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my $sql = qq/select params,origin,modelset,ran_on from v_run_history where pseq_id=$v->{pseq_id}/;
my $ar;

$ar = $u->selectall_arrayref($sql);

#try {
#  $ar = $u->selectall_arrayref($sql);
#} catch Unison::Exception with {
#  $p->die('SQL Query Failed',
#		  $sql,$_[0]);
#};


my @f = qw(params origin modelset ran_on);
print $p->render("Run history for Unison:$v->{pseq_id}",
				 $p->best_annotation($v->{pseq_id}),
				 $p->group("Run History",
						   Unison::WWW::Table::render(\@f,$ar)),
				 $p->sql($sql)
				);

