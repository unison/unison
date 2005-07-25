#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use CGI( -debug );
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};

print $p->render('News', <<EOHTML);
<table align=center width=80% border=1>

<tr><td>
<h3>2005-05-17</h3>

<p>The most significant user-visible changes in the production database are:
<ul>
<li> updated computations on everything (of course)
<li> materialized view of "best" annotations for each sequence
<li> best_alias and best_annotation functions are faster
<li> NEW: Pfam 17.0 predictions (ls and fs)
<li> NEW: bigpi predictions (in pfbigpi table)
<li> NEW: protcomp predictions (in psprotcomp table), see also v_psprotcomp view
<li> NEW: pdb schema, with PDB file, chain, and ligand summaries
<li> NEW: PDB seqres-to-resid mapping (allows translation of coordinates from a query sequence to a 3D coordinate)
</ul>

<p>The new API in installed on geneland. The database and API should be
backward compatible.

<p>The most important change in the web interface is the addition inline
viewing of both threading models and sequence features-on-structure. The
inline viewer uses the Jmol applet and doesn't require manual code
download. (The Jmol applet doesn't work with Firefox.)

<p>One of the features we added is the ability for users to identify and
display their own features via a URL. For an example, try: <a
href="http://csb:8080/unison/cgi/pseq_structure.pl?q=8949;userfeatures=mydomain%4025-50,mysnp%4040">http://csb:8080/unison/cgi/pseq_structure.pl?q=8949;userfeatures=mydomain\@25-50,mysnp\@40</a>
Then click on mydomain, then mysnp.

<p>Tip: The q= in the URL can be almost anything sane, like q=PRO123,
NP_98765.4, or even UNQ456 and DNA789.
</td></tr>

</table>
EOHTML
