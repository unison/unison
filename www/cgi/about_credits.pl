#!/usr/bin/env perl

use strict;
use warnings;
use CGI( -debug );
use Data::Dumper;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my $sql = qq/select * from meta/;
my $ar = $u->selectall_arrayref($sql);
my @f = qw( key value );

my $thanks = <<EOF;
<p>Many thanks to the developers of the follow freely available packages:
<table width="80%">
<tr>
	<td align="center"></td>
	<td align="left"><a href="http://gwiz/groups/Bioinfo/">Genentech Bioinformatics Department</a></td>
</tr>

<tr>
	<td align="center"><img height=20 src="../av/feather.gif"></td>
	<td align="left"><a href="http://www.apache.org/">Apache web server</a></td>
</tr>

<tr>
	<td align="center"></td>
	<td align="left"><a href="http://www.bioperl.org/">BioPerl</a></td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/GOthumbnail.gif" alt="GO"></td>
	<td align="left"><a href="http://www.geneontology.org/">GeneOntology.org</a></td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/gnome-logo-icon-transparent.png" alt="GNOME"></td>
	<td align="left"><a href="http://www.gnome.org/">GNOME</a></td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/gnu-head-sm.jpg" alt="GNU/FSF"></td>
	<td align="left"><a href="http://www.gnu.org">GNU/Free Software Foundation</a> tools
	</td>
</tr>

<tr>
	<td align="center"></td>
	<td align="left"><a href="http://hmmer.wustl.edu/">HMMER</a></td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/linux-penguin-sm.gif" alt="Linux"></td>
	<td align="left"><a href="http://www.linux.org/">Linux</a> (Linus Torvalds and linux-gnu contributors)</td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/ncbi.gif" alt="NCBI"></td>
	<td align="left"><a href="http://www.ncbi.nlm.nih.gov/">NCBI</a> for CDD, RefSeq</td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/oo-logonew.gif" alt="OpenOffice"></td>
	<td align="left"><a href="http://www.openoffice.org">OpenOffice</a></td>
</tr>

<tr>
	<td align="center"><img height=30 src="../av/camel.png"></td>
	<td align="left"><a href="http://www.perl.com/">Perl</a> (Larry Wall and perl contributors)</td>
</tr>

<tr>
	<td align="center"></td>
	<td align="left"><a href="http://pfam.wustl.edu/">Pfam</a></td>
</tr>

<tr>
	<td align="center"></td>
	<td align="left"><a href="http://scop.berkeley.edu/">SCOP - Structural Classifcation of Proteins</a></td>
</tr>

<tr>
	<td align="center"></td>
	<td align="left"><a href="http://www.vladdy.net/webdesign/Tooltips.html">Vladdy.net</a> for tooltips JavaScript</td>
</tr>

</table>
EOF

print $p->render("Unison: Credits",
				 $thanks
				);
