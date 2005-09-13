#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

sub meta_group($);
sub params_group($);
sub porigin_group($);

my $p = new Unison::WWW::Page;

print $p->render("Contents and Meta Information",
				 meta_group($p),
				 porigin_group($p),
				 params_group($p)
				);

exit(0);



sub meta_group($) {
  my $p = shift;
  my $u = $p->{unison};
  my $sql = 'select * from meta order by 1';
  my $sth = $u->prepare( $sql );
  my $ar = $u->selectall_arrayref($sth);
  my @cols = @{ $sth->{NAME} };
  return $p->group("Meta",
				   Unison::WWW::Table::render(\@cols,$ar));
}

sub params_group($) {
  my $p = shift;
  my $u = $p->{unison};
  my $sql = 'select name,descr,commandline from params order by name';
  my $sth = $u->prepare( $sql );
  my $ar = $u->selectall_arrayref($sth);
  my @cols = @{ $sth->{NAME} };
  return $p->group("Execution Parameters",
				   Unison::WWW::Table::render(\@cols,$ar));
}


sub porigin_group($) {
  my $p = shift;
  my $u = $p->{unison};
  my $sql = 'select origin,descr,ann_pref,url from porigin where ann_pref is not null order by ann_pref,origin';
  my $sth = $u->prepare( $sql );
  my $ar = $u->selectall_arrayref($sth);
  my @cols = @{ $sth->{NAME} };
  return $p->group("Data Sources",
				   Unison::WWW::Table::render(\@cols,$ar));
}
