#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison;
use Unison::Exceptions;
use Unison::WWW::Page qw(skip_db_connect);


my $p = new Unison::WWW::Page();

print $p->render('Download', <<EOBODY);

<dl>

<dt>Source Code

<dd>Unison is <a href="http://sourceforge.net/projects/unison-db/">hosted
at SourceForge</a>.

<p>The Unison source code contains raw the SQL schema, Perl modules,
scripts, Makefiles for data loading, and a lot more.  Please see the <a
class="ext_link" target="_blank"
href="http://sourceforge.net/svn/?group_id=140591">subversion instructions
on SourceForge</a> for information about obtaining the source code.  You
may also <a class="ext_link" target="_blank"
href="http://unison-db.svn.sourceforge.net/viewvc/unison-db/">browse the
subversion repository</a> with viewvc on SourceForge.


<dt>Database Dumps
<dd>The public database dumps contain non-proprietary sequences and
predictions.  This typically includes all sequences from all species and
all sources available at the time of release, as well as predictions on
most human, mouse, rat, yeast, drosophila, and zebrafish proteins.  More
can be computed and loading using the scripts in the source code
distribution.

<!-- all instances point to the public database dumps rather than the local dumps dir -->
<br><iframe frameborder=0 width="100%" src="http://unison-db.org/dumps"></iframe>
</dd>

</dl>

EOBODY
