#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};

print $p->render("About Unison", <<EOHTML );

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

