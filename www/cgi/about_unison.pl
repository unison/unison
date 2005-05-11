#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

print $p->render("About Unison", <<EOT );

<DIV STYLE="overflow: auto; height: 400px; padding:0px; margin: 0px">

<h3>WHAT IS UNISON, IN A NUTSHELL?</h3>

Unison is a database of non-redundant protein sequences, extensive
precomputed sequence- and structure-based predictions for those sequences,
and auxiliary information which facilitates the interpretation of these
predictions.  The intent is to integrate data types in order to enable
meaningful, holistic queries.  Because results are precomputed and indexed
for fast access, Unison enables answers to complex queries that were
previously impractical.


<h3>WHAT CAN I DO WITH UNISON?</h3>
<dl>
  <dt><b>Answer complex, integrative queries efficiently.</b>
  <dd>Because precomputed results and auxiliary data are integrated within one resource,
  it is possible construct holistic queries and test complex
  hypotheses. [ITIM EXAMPLE]

  <dt><b>Generate <i>in silico</i> hypotheses.</b>
  <dd>Precomputed results also enable rapid responses to "what-if?"
  questions and the formulation of new hypotheses. [ITIM EXAMPLE]

  <dt><b>Analyze protein structure models.</b>
  <dd>Unison's bread and butter is protein structural analyses. Unison
  provides comprehensive sequence-sequence, sequence-profile,
  sequence-structure, and structure-structure alignments. These provide
  mechanisms to, for example, explore the structural effects of sequence
  variants (even on modeled structures) and to study the sequence
  divergence among structurally related proteins. [SNP EXAMPLE] [KINASE
  GATEKEEPER EXAMPLE]
</dl>


<h3>HOW DOES UNISON WORK?</h3>

<p>Sequences in Unison are culled from numerous sources and include both
well-annotated sequences (<i>e.g.,</i> from UniProt, Derwent Geneseq) and
speculative sequences (<i>e.g.,</i> from Ensembl, gene transcript
predictions, raw 6-frame translations).  Sequences are stored
<i>non-redundandtly</i> and are given a permanent identifier, a
<code>pseq_id</code>.  Sequences are never deleted or modified, and the
corresponding <code>pseq_id</code> is never changed. [<a
href="pseq_summary.pl?pseq_id=76">example</a>]

<p>Of course, sequences are imported from highly redundant source
databases.  The source databases, accessions, and descriptions of each
sequence are stored in Unison and provide a record of when a sequence was
loaded. [<a href="pseq_paliases.pl?pseq_id=76">example</a>].  Each origin
is ranked for its reliability and informative content, and this is the
basis for providing a heuristic "best annotation" for each sequence as
seen in the example.

<p>After sequences are loaded, a set of sequences which are most likely to
be reliable targets is built based on origin, species, and other
properties.  These sequences are subjected to an array of algorithms whose
results are stored.  The predictions currently include signal sequence,
transmembrane prediction, GPI anchoring, antigenicity, and alignments from
BLAST, HMM (Pfam) alignments, and threading, and many others.  Unison's
bookkeeping about which algorithms have been run (and how) provides a
powerful mechanism for keeping Unison sequences and results up to date.

<p>All precomputed results are linked directly to the pseq_id [<a
href="pseq_features.pl?pseq_id=76">example</a>].  And because precomputed
results are linked to immutable sequences, there's no issue about results
being "stale" with respsect to a changed sequence.  Unison also
distinguishes results by algorighm parameters, and this permits users to
compare several sets of analyses.

<p>Unison integrates many other data sources which are useful in
querying. For example, NCBI's Homologene enables queries to require that a
human putative target also has a homolog in mouse or rat with similar
protein features.  Patents, Gene Ontology, NCBI taxonomy, and genomic
localization are also available in Unison.


<h3>HOW DO I GET STARTED?</h3>

<p>Most users will access Unison via the web interface.  Here are some
searches to get you started:

<ul>
<li>If you've got a favorite protein, <a
href="search_by_alias.pl">search for it by accession</a>.  Once you've
identified a sequence, you may click the tabs to show details of the
precomputed results.

<li>Users may also wish to <a href="search_by_properties.pl">mine for
sequences by properties</a>.

<li>Finally, "<a href="browse_views.pl">canned views</a>" provide
saved search strategies and are good starting points for common searches.
(Send Reece mail if you want to design other views.)
</ul>

</DIV>
EOT

