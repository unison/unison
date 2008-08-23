#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison;
use Unison::Exceptions;
use Unison::WWW::Page qw(skip_db_connect);


my $p = new Unison::WWW::Page();

print $p->render('Getting It', <<EOBODY);

<dl>

<dt>Source code

<dd>Unison is <a href="http://sourceforge.net/projects/unison-db/">hosted
at SourceForge</a>.

<p>The Unison source code contains raw the SQL schema, Perl modules,
scripts, Makefiles for data loading, and a lot more.  Users may <a
class="ext_link" target="_blank"
href="http://sourceforge.net/svn/?group_id=140591">get a local copy</a> of
the source code via subversion.

<p>You may <a class="ext_link" target="_blank"
href="http://unison-db.svn.sourceforge.net/viewvc/unison-db/">browse the
subversion repository</a> with viewvc on SourceForge. [NOTE: SourceForge
is stabilizing the viewvc interface. If the viewvc interface is offline,
you can probably still <a class="ext_link" target="_blank"
href="http://unison-db.svn.sourceforge.net/svnroot/unison-db/trunk/">browse
the repository directly</a>.]


<dt>Public database dumps
<dd>Public database dumps are available here:
<!-- all instances point to the public database dumps rather than the local dumps dir -->
<br><iframe frameborder=0 width="100%" src="http://unison-db.org/dumps"></iframe>
</dd>

</dl>

EOBODY
