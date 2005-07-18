#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;


my $p = new Unison::WWW::Page;
my $u = $p->{unison};

my $sql = 'select * from meta order by 1';
my $ar = $u->selectall_arrayref($sql);
my @f = qw( key value );

print $p->render("Unison contents and Meta Information",
				 $p->group("Meta",
						   Unison::WWW::Table::render(\@f,$ar)),
				 $p->sql($sql)
				);
