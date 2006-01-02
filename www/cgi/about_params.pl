#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::SQL;

my $star = '<span style="color: red;">*</span>';

sub params_group($);

my $p = new Unison::WWW::Page;
$p->add_footer_lines('$Id: about_params.pl,v 1.2 2005/11/21 20:24:18 rkh Exp $ ');

print $p->render("Available parameters",
				 "$star indicates proprietary methods",
				 params_group($p)
				);

exit(0);


sub params_group($) {
  my $p = shift;
  my $u = $p->{unison};
  my $sql = "select params_id,name||(case is_public when false THEN '*' else '' end) as name,descr,commandline from params order by upper(name)";
  my $sth = $u->prepare( $sql );
  my $ar = $u->selectall_arrayref($sth);
  for(my $i=0; $i<=$#$ar; $i++) {
	$ar->[$i][1] =~ s/\s+/&nbsp;/g;
	$ar->[$i][1] =~ s/\*/$star/;

	$ar->[$i][2] =~ s%(http://.+db=pubmed\S+)%<a href="$1">[PubMed reference]</a>%
	  || $ar->[$i][2] =~ s%(http://\S+)%<a href="$1">$1</a>%;

	$ar->[$i][3] = "<code>$ar->[$i][3]</code>";
  }
  my @cols = @{ $sth->{NAME} };
  return $p->group("Execution Parameters",
				   Unison::WWW::Table::render(\@cols,$ar));
}


