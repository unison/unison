#!/usr/bin/env perl

use strict;
use warnings;
use CGI( -debug );
use Data::Dumper;
BEGIN
  {
  if (exists $ENV{SCRIPT_FILENAME})
	{ ($ENV{PWD}) = $ENV{SCRIPT_FILENAME} =~ m%^(.*/)%; }
  }
use lib $ENV{PWD}."/../perl5";
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my $sql = qq/select * from meta/;
my $ar = $u->selectall_arrayref($sql);
my @f = qw( key value );

my $thanks = <<EOF;
<p>Many thanks to:
<table width="80%">
<tr>
	<td align="center"><img height=30 src="../av/poweredby_postgresql.png"></td>
	<td align="left"><a href="http://www.postgreqsql.org/">PostgreSQL</a></td>
</tr>
<tr>
	<td align="center"><img height=30 src="../av/feather.gif"></td>
	<td align="left"><a href="http://www.apache.org/">Apache web server</a></td>
</tr>
<tr>
	<td align="center"></td>
	<td align="left"><a href="http://www.bioperl.org/">BioPerl</a></td>
</tr>
<tr>
	<td align="center"><img height=30 src="../av/camel.png"></td>
	<td align="left"><a href="http://www.perl.com/">Perl</a> (Larry Wall and perl contributors)</td>
</tr>
<tr>
	<td align="center"></td>
	<td align="left"><a href="http://www.linux.com/">Linux</a> (Linus Torvalds and linux-gnu contributors)</td>
</tr>
<tr>
	<td align="center"><img height=30 src="../av/gnome-logo-icon-transparent.png" alt="GNOME"></td>
	<td align="left"><a href="http://www.gnome.org/">GNOME</a></td>
</tr>
<tr>
	<td align="center"></td>
	<td align="left"><a href="http://www.vladdy.net/webdesign/Tooltips.html">Vladdy.net</a> for tooltips JavaScript</td>
</tr>
<tr>
	<td align="center"></td>
	<td align="left"><a href="http://gwiz/groups/Bioinfo/">Genentech Bioinformatics Department</a></td>
</tr>
</table>
EOF

print $p->render("Unison: Credits",
				 $thanks
				);
