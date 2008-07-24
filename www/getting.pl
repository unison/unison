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

<p>SourceForge has temporarily disabled web-based browsing of all
repositories with viewvc.  The subversion repository remains available for
local copies.  You can <a
href="http://unison-db.svn.sourceforge.net/svnroot/unison-db/trunk/">browse
the raw files (without viewvc)</a>.


<dt>Public database dumps
<dd>Public database dumps are available here:
<br><iframe frameborder=0 width="100%" src="dumps"></iframe>
</dd>

</dl>

EOBODY
