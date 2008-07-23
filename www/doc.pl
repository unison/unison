#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison;
use Unison::Exceptions;
use Unison::WWW::Page qw(skip_db_connect);


my $p = new Unison::WWW::Page();

print $p->render('Documentation', <<EOBODY);

We are actively working on organizing and building better Unison
documentation.  In the meantime, here's what we currently have available:

<dl>

<dt><a href="doc/unison-tutorial.pdf">Tutorial</a>
<dd>Provides a brief introduction to connecting and using Unison, with
examples.</dd>

<dt><a href="doc/critical-tables.pdf">Critical Tables</a>
<dd>An entity-relationship diagram of the most frequently used tables in
Unison.</dd>

<dt><a target="_blank" href="tour">Web Tour</a>
<dd>A small set of web pages with example queries and discussion.</dd>

<dt>Unison paper
<dd>In review. When published, the paper will appear here.</dd>

<dt>Automated Schema documentation
<dd>in preparation</dd>

<dt>Installation notes
<dd>in preparation</dd>

<dt><a href="http://unison-db.wiki.sourceforge.net/">Wiki</a>
<dd>Sourceforge hosts a wiki for Unison.  Most or all of our documentation
will eventually reside there.

<dt>Mailing lists
<dd>Users may wish to subscribe to the moderated, low-volume <a
href="http://lists.sourceforge.net/lists/listinfo/unison-db-announce">unison-db-announce</a>
mailing list.  We will likely make a user mailing list as well.  </dd>

<dt>Mail the authors
<dd>Send email to unison-db at unison.org.</dd>

</dl>

EOBODY
