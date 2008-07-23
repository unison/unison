#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison;
use Unison::Exceptions;
use Unison::WWW::Page qw(skip_db_connect);


my $p = new Unison::WWW::Page();

print $p->render('License', <<EOBODY);
Unison Protein Database &mdash; http://unison-db.org/
<br>Copyright &copy; 2002-2008 Reece Hart, Genentech, Inc.
<br>Licensed under the
<a href="http://opensource.org/licenses/afl-3.0.php">Academic Free License version 3.0</a>
<br>The text of the license is show below.

<p>Source data are distributed pursuant to their respective
licenses.

<p>

<iframe height="400" width="100%" frameborder=1 src="LICENSE">
</iframe>
EOBODY


