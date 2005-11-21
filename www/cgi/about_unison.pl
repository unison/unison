#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;

my $p = new Unison::WWW::Page;
$p->add_footer_lines('$Id: pseq_summary.pl,v 1.41 2005/11/21 18:00:26 rkh Exp $ ');


print $p->render("About Unison", <<EOHTML, _conn_info_html($p) );

Unison is a comprehensive database of protein sequences and precomputed
sequence prediction results.  Integration of these data enables
informative queries regarding protein families, structure, and function.

<p>The Unison schema, precomputed data, API, and web interface are
released to the public under the <a target="_blank"
href="http://opensource.org/licenses/afl-2.1.php">Academic Free
License</a>.  The Unison web site and PostgreSQL database backend
available to all users.

<p>Please see the <a href="../index.html">Unison Home Page
(http://unison-db.org/)</a> for more information about the Unison project,
<a href="../credits.html">credits</a>, <a href="../LICENSE">license</a>,
documentation, direct database connection instructions, a guided tour, and
download sites.

EOHTML


sub _conn_info_html ($) {
  my $p = shift;
  my $info = 'not connected to the Unison database';

  if (ref $p and defined $p->{unison} and $p->{unison}->is_open()) {
	my $www_state = ( $p->is_dev_instance() 
					  ? '<span style="color: red">development</span>'
					  : '');
	my $db_rel = $p->{unison}->selectrow_array('select value::date from meta where key=\'release timestamp\'') || '';
	my $db_host = $p->{unison}->{host} ? "$p->{unison}->{host}:$p->{unison}->{port}" : 'local';



	$info = <<EOHTML;
<center>
<table class="sw_stack">

<tr>
<th>web</th>
<td>
release: $Unison::WWW::RELEASE $www_state
<br>host: $ENV{SERVER_NAME}
<br>client: $ENV{REMOTE_ADDR}
<br>user: $ENV{REMOTE_USER}
</td>
</tr>

<tr>
<th>API</th>
<td>
release: $Unison::RELEASE
<br>path: $INC{'Unison.pm'}
</td>
</tr>

<tr>
<th>database</th>
<td>
release: $db_rel
<br>host:port: $db_host
<br>database $p->{unison}->{dbname}
<br>username: $p->{unison}->{username}
</td>
</tr>

</table>
</center>

EOHTML
  }

  return $info;
}
