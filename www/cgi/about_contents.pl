#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::SQL;


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
  my $sql = 'select name||(case is_public when false THEN \'*\' else \'\' end) as name,descr,commandline from params order by name';
  my $sth = $u->prepare( $sql );
  my $ar = $u->selectall_arrayref($sth);
  my @cols = @{ $sth->{NAME} };
  return $p->group("Execution Parameters",
				   Unison::WWW::Table::render(\@cols,$ar));
}


sub porigin_group($) {
  my $p = shift;
  my $u = $p->{unison};
  my $sql = new Unison::SQL;
  $sql->columns('origin||(case is_public when false THEN \'*\' else \'\' end) as origin',
				'to_char(last_updated,\'YYYY-MM-DD\') as "last updated"',
				'descr', 'url')
    ->table('porigin')
	->where('ann_pref is not null')
	->order('origin');
  $sql->where('is_public=TRUE') if $u->is_public();

  my $sth = $u->prepare( "$sql" );
  my $ar = $u->selectall_arrayref($sth);
  my @cols = @{ $sth->{NAME} };
  for (my $i=0; $i<=$#$ar; $i++) {
	$ar->[$i][3] = "<a href=\"$ar->[$i][3]\">$ar->[$i][3]</a>" if defined $ar->[$i][3];
  }
  return $p->group("Data Sources",
				   Unison::WWW::Table::render(\@cols,$ar));
}
