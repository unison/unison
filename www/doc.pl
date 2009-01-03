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

<dt>Installation notes
<dd>in preparation</dd>

<dt><a href="doc/unison-tutorial.pdf">Tutorial</a>
<dd>Provides a brief introduction to connecting and using Unison, with
examples.</dd>

<dt>Automated Schema documentation
<dd>in preparation</dd>

<dt><a href="doc/critical-tables.pdf">Critical Tables</a>
<dd>An entity-relationship diagram of the most frequently used tables in
Unison.</dd>

<dt><a target="_blank" href="tour">Web Tour</a>
<dd>A small set of web pages with example queries and discussion.</dd>

<dt>Papers about or using Unison
<dd>
  <dl style="background: #ddd;">

  <dt>Unison: An Integrated Platform for Computational Biology Discovery
  <dd>Hart RK, Mukhyala K
  <br><a href="http://psb.stanford.edu/">Pacific Symposium on Biocomputing</a> <a href="http://harts.net/reece/pubs/2009/unison-psb-2009.pdf">PDF</a>
  </dd>

  <dt>Natural selection of protein structural and functional properties: a single nucleotide polymorphism perspective.
  <dd>Liu J, Zhang Y, Lei X, Zhang Z.
  <br>Genome Biol. 2008 Apr 8;9(4):R69.
      <a href="http://www.ncbi.nlm.nih.gov/pubmed/18397526">PubMed</a>
  </dd>

  <dt>Functional characterization of the Bcl-2 gene family in the zebrafish.
  <dd>Kratz E, Eimon PM, Mukhyala K, Stern H, Zha J, Strasser A, Hart R, Ashkenazi A.
  <br>Cell Death Differ. 2006 Oct;13(10):1631-40.
      <a href="http://www.ncbi.nlm.nih.gov/pubmed/16888646">PubMed</a>
  <br>(Also see our <a
  href="http://harts.net/reece/pubs/2005/zfish-bcl2/manuscript.pdf">unpublished
  manuscript</a> that provides details about the computational discovery
  of these proteins.)
  </dd>

  </dl>
</dd>

<dt><a href="http://unison-db.wiki.sourceforge.net/">Wiki</a>
<dd>Sourceforge hosts a wiki for Unison.  Most or all of our documentation
will eventually reside there.

<dt>Mailing lists
<dd>Users may wish to subscribe to the moderated, low-volume <a
href="http://lists.sourceforge.net/lists/listinfo/unison-db-announce">unison-db-announce</a>
mailing list.  We will likely make a user mailing list as well.  </dd>

<dt><a href="mailto:unison\@unison-db.org?Subject=Unison">Mail the authors</a>
<dd>Send email to unison at unison-db.org.</dd>

<dt><a href="http://sourceforge.net/tracker/?group_id=140591">Bugs and Feature Requests</a>
<dd>Bugs and feature requests may be browsed or filed. Code submissions are welcome!</dd>

</dl>

EOBODY
