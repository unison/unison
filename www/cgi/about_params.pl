#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::SQL;


sub params_group($);

my $p = new Unison::WWW::Page;

print $p->render("Available parameters",
				 '* indicates proprietary methods',
				 params_group($p)
				);

exit(0);


sub params_group($) {
  my $p = shift;
  my $u = $p->{unison};
  my $sql = 'select name||(case is_public when false THEN \'*\' else \'\' end) as name,descr,commandline from params order by name';
  my $sth = $u->prepare( $sql );
  my $ar = $u->selectall_arrayref($sth);
  my @cols = @{ $sth->{NAME} };
  return $p->group("Execution Parameters",
				   Unison::WWW::Table::render(\@cols,$ar));
}


