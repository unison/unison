#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison;
use Unison::Exceptions;
use Unison::WWW::Page qw(skip_db_connect);


my $p = new Unison::WWW::Page();

print $p->render('Screenshots', <<EOBODY);
<h1>Unison Screenshots</h1>

<table class="shots">

<tr>
  <th><a class="nofeedback" href="av/ss-summary.png"><img src="av/ss-summary-sm.png"></a></th>
  <td>The Unison summary page for a specified sequence.</td>
</tr>

<tr>
  <th><a class="nofeedback" href="av/ss-aliases.png"><img src="av/ss-aliases-sm.png"></a></th>
  <td>Aliases are the identifiers and accessions by which a sequence is
  known. Most sequences appear in multiple databases (sometimes multiple
  times), but they're stored non-redundantly in Unison. This page shows
  all of the aliases for a given sequence.</td>
</tr>

<tr>
  <th><a class="nofeedback" href="av/ss-patents.png"><img src="av/ss-patents-sm.png"></a></th>
  <td>Sequences from NCBI's patent database within a user-specifiable
  neighborhood of a query. Derwent Geneseq sequences will also be shown if
  available, but these are not included in the public release.
  </td>
</tr>

<tr>
  <th><a class="nofeedback" href="av/ss-loci.png"><img src="av/ss-loci-sm.png"></a></th>
  <td>Most human sequences are aligned to the Human Genome
  using <a href="http://share.gene.com">pmap</a> (Tom Wu, Colin Watanabe).
  This page summarizes those alignments.
</td>
</tr>

<tr>
  <th><a class="nofeedback" href="av/ss-functions.png"><img src="av/ss-functions-sm.png"></a></th>
  <td>GO and NCBI GeneRIFs (References into Function)</td>
</tr>

<tr>
  <th><a class="nofeedback" href="av/ss-features.png"><img src="av/ss-features-sm.png"></a></th>
  <td>All predicted sequence features on one panel. Mouseovers on features
  provide a digest of the feature, and most features provide links to
  models or source data.</td>
</tr>

<tr>
  <th><a class="nofeedback" href="av/ss-structure.png"><img src="av/ss-structure-sm.png"></a></th>
  <td>Structure and domain visualization using JMol. Domains, SNPs, and
  other features stored in Unison may be selected and displayed on
  structure.  This page also supports the display of features that are
  specified by URL query arguments.
 </td>
</tr>

</table>
EOBODY
