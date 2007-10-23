#!/usr/bin/perl

use strict;
use warnings;

my $ql_table = join('',<DATA>);
my $ql_start_tag = "<!-- quicklinks start -->\n";
my $ql_end_tag = "<!-- quicklinks end -->\n";

local $/ = undef;

while( my $fn = shift ) {
  my $bakfn = "$fn.bak";
  if ( -e $bakfn ) {
	warn("$bakfn: already exists; skipping $fn\n");
	next;
  }

  open(F,"<$fn")
	|| die("$fn: $!\n");
  my $html = scalar <F>;
  close(F);

  my $my_ql_table = $ql_table;
  $html =~ s/$ql_start_tag.*$ql_end_tag/$ql_start_tag$my_ql_table$ql_end_tag/s;
  if (not $&) {
	warn("$fn: no substitution tags found\n");
	next;
  }

  my $newfn = "$fn.tmp";
  open(F,">$newfn")
	|| die("$newfn: $!\n");
  print(F $html);
  close(F);

  rename($fn,$bakfn)
	|| die("rename($fn,$bakfn): $!\n");
  rename($newfn,$fn)
	|| die("rename($fn,$bakfn): $!\n");

  print("processed $fn\n");
}






__DATA__
<SCRIPT TYPE="text/javascript" SRC="searchplugin/webinstall.js"></script>
<table width="100%" border=0>
  <tr>
	<td valign="top">
	  <span style="font-size: 150%; font-weight: bold;">Welcome to</span>
	  <br><img src="av/logo5.png" alt="[Unison Logo]">
	  <br><i>integrated, precomputed proteomic predictions for rapid
	  feature-based mining, sequence analysis, and hypothesis generation</i>
	</td>

	<td valign="top" align="right">
	 <table class=quicklinks>
	  <tr><td colspan=2 class="quicklinks_title" align=center><b>quick
		 links</b></td></tr>

	  <tr>
	   <td class="quicklinks_title">info</td>
	   <td class=quicklinks>
	     <a href="index.html">home</a> 
       | <a href="moreinfo.html">more info</a>
  <!-- | <a href="docs/index.html">docs</a> -->
       | <a href="tour/index.html">tour</a> | <a href="http://sourceforge.net/project/screenshots.php?group_id=140591">screenshots</a>
	   | <a href="license.html">license</a> | <a href="credits.html">credits</a>
	   </td>
	  </tr>

	  <tr>
	   <td class="quicklinks_title">contacts</td>
	   <td class=quicklinks><a href="http://sourceforge.net/tracker/?atid=759616&amp;group_id=140591&amp;func=browse">issue tracker</a> | <a href="http://lists.sourceforge.net/lists/listinfo/unison-db-announce">announcment mailing list</a></td>
	  </tr>

	  <tr>
	   <td class="quicklinks_title">develop</td>
	   <td class=quicklinks><a href="http://sourceforge.net/projects/unison-db/">SourceForge</a> | <a href="http://sourceforge.net/project/showfiles.php?group_id=140591">download code &amp; data</a></td>
	  </tr>

	  <tr>
	   <td class="quicklinks_title">tools</td>
	   <td class=quicklinks><a href="javascript:addUnisonEngine()">Firefox search engine</a></td>
	  </tr>

	 </table>
	</td>
  </tr>
</table>
