#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;

sub _conn_info_html($);

my $p = new Unison::WWW::Page;
$p->add_footer_lines('$Id: about_unison.pl,v 1.17 2006/01/02 05:41:11 rkh Exp $ ');


print $p->render("About Unison", <<EOHTML, _conn_info_html($p) );

Unison is a comprehensive database of protein sequences and precomputed
sequence prediction results.  Integration of these data enables
informative queries regarding protein families, structure, and function.

<p>The Unison schema, precomputed data, API, and web interface are
released to the public under the <a target="_blank"
href="http://opensource.org/licenses/afl-2.1.php">Academic Free
License</a>.  The Unison web site and PostgreSQL database backend
available to all users.

<p>Please see the <a href="../index.html">Unison Home Page</a> for more
information about the Unison project, <a
href="../credits.html">credits</a>, <a href="../license.html">license</a>,
documentation, direct database connection instructions, a guided tour, and
download sites.

EOHTML


sub _conn_info_html ($) {
  my $p = shift;
  my $u = $p->{unison};
  my $info = 'not connected to the Unison database';

  if (ref $p and defined $u and $u->is_open()) {
	my $dev_str = '<span style="color: red">development</span> (no release tag)';
	my $pub_str = '<span style="color: green">public</span>';
	my $www_rel = ($p->is_public_instance ? $pub_str : '') . ' ' . ($Unison::WWW::RELEASE || $dev_str);
	my $api_rel = $Unison::RELEASE || $dev_str;
	my $db_rel = ($u->is_public_instance ? $pub_str : '') . ' ' . ($u->release_timestamp() || $dev_str);

	my $db_host = $u->{host}
	  ? sprintf("%s:%s",$u->{host},$u->{port}||'&lt;default&gt;')
	  : 'local';

	$info = <<EOHTML;
<center>
<table class="sw_stack">
<tr><th rowspan=4>web</th>		<td><b>release:</b></td>	<td>$www_rel</td></tr>
<tr>                      		<td><b>host:</b></td>	  	<td>$ENV{SERVER_NAME}</td></tr>
<tr>							<td><b>client:</b></td>  	<td>$ENV{REMOTE_ADDR}</td></tr>
<tr>							<td><b>user:</b></td>	  	<td>$ENV{REMOTE_USER}</td></tr>

<tr><td colspan=3 class="sw_stack_sep"></td></tr>

<tr><th rowspan=2>API</th>		<td><b>release:</b></td>	<td>$api_rel</td></tr>
<tr>							<td><b>path:</b></td>		<td>$INC{'Unison.pm'}</td></tr>

<tr><td colspan=3 class="sw_stack_sep"></td></tr>

<tr><th rowspan=4>database</th>	<td><b>release:</b></td>	<td>$db_rel</td></tr>
<tr>							<td><b>host:port:</b></td>	<td>$db_host</td></tr>
<tr>							<td><b>database:</b></td>	<td>$u->{dbname}</td></tr>
<tr>							<td><b>username:</b></td>	<td>$u->{username}</td></tr>

</table>
</center>

EOHTML
  }

  return $info;
}
