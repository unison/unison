#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::SQL;


sub origin_group($);

my $p = new Unison::WWW::Page;
$p->add_footer_lines('$Id: about_origins.pl,v 1.3 2006/02/15 04:06:57 rkh Exp $ ');

# FIXME: make * red, as in about_params

print $p->render("Data Sources (Origins)",
				 '* indicates proprietary data',
				 origin_group($p),
				);

exit(0);


sub origin_group($) {
  my $p = shift;
  my $u = $p->{unison};
  my $sql = new Unison::SQL;
  $sql->columns('origin||(case is_public when false THEN \'*\' else \'\' end) as origin',
				'to_char(last_updated,\'YYYY-MM-DD\') as "last updated"',
				'descr', 'url')
    ->table('origin')
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
