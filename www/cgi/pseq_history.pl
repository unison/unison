#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::Exceptions;
use Error qw(:try);


my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$p->add_footer_lines('$Id: pseq_history.pl,v 1.5 2005/06/18 00:16:45 rkh Exp $ ');


my $sql = qq/select params,origin,modelset,ran_on from v_run_history where pseq_id=$v->{pseq_id}/;
my $ar;


try {
  $ar = $u->selectall_arrayref($sql);
} catch Unison::Exception with {
  $p->die('SQL Query Failed',
		  $_[0],
		  $p->sql($sql));
};


my @f = qw(params origin modelset ran_on);
print $p->render("Run history for Unison:$v->{pseq_id}",
				 $p->best_annotation($v->{pseq_id}),
				 '<p>',
				 $p->group("Run History",
						   Unison::WWW::Table::render(\@f,$ar)),
				 $p->sql($sql)
				);

