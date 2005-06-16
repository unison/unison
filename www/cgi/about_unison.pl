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

print $p->render("About Unison", <<EOHTML );

<!-- DIV STYLE="overflow: auto; height: 400px; padding:0px; margin: 0px" -->

<h3>WHAT IS UNISON, IN A NUTSHELL?</h3>

Unison is a database of non-redundant protein sequences and extensive
<i>precomputed</i> predictions for those sequences.  Unison's primary
mission is to enable Genentech to ask and answer proteomic queries for
target discovery more efficiently, more completely, more reliably, and
more often, and to enable queries which were previously impractical.


<h3>WHAT CAN I DO WITH UNISON?</h3>
<dl>
  <dt><b>Answer complex, integrative queries efficiently.</b> <dd>Because
  precomputed results and auxiliary data are integrated within one
  resource, it is possible construct holistic queries which span multiple
  types and sources of data. For example: Identify distinct sequences
  which contain an extracellular immunoglobulin (ig) domain by Pfam,
  followed by a transmembrane region, followed by an Immunoreceptor
  Tyrosine Inhibitory Motif (ITIM).

  <dt><b>Analyze protein structure models.</b>
  <dd>Unison provides comprehensive sequence-sequence, sequence-profile,
  sequence-structure, and structure-structure alignments. These provide
  mechanisms to, for example, explore the structural effects of sequence
  variants (even on modeled structures) and to study the sequence
  divergence among structurally related proteins. <!--[SNP EXAMPLE]-->
  <!--[KINASE GATEKEEPER EXAMPLE]-->

  <dt><b>Generate <i>in silico</i> hypotheses.</b>
  <dd>Precomputed results also enable rapid responses to "what-if?"
  questions and the formulation of new hypotheses. For example: What
  Pfam domains occur upstream of a transmembrane domain and an ITIM?
  Unison answers this in 30 seconds.
</dl>


<h3>HOW DO I GET STARTED?</h3>

<p>Most users will access Unison via the web interface.  Here are some
searches to get you started:

<ul>
<li>If you've got a favorite protein, <a
href="search_by_alias.pl">search for it by accession</a>.  Once you've
identified a sequence, you may click the tabs to show details of the
precomputed results.

<li>If you'd like to find proteins with particular features, try <a
href="search_by_properties.pl">searching for sequences by
properties</a>.

<li>Finally, "<a href="browse_views.pl">canned views</a>" provide
saved search strategies and are good starting points for common searches.
(Send Reece mail if you want to design other views.)
</ul>

<!-- /DIV -->
EOHTML




__END__

<h3>HOW DOES UNISON WORK?</h3>

<p>Sequences in Unison are culled from numerous sources and include both
well-annotated sequences (<i>e.g.,</i> from UniProt, Derwent Geneseq) and
speculative sequences (<i>e.g.,</i> from Ensembl, gene transcript
predictions, raw 6-frame translations).  The intent is to provide a
superset of all available sequences. Sequences are stored
<i>non-redundandtly</i> and are given a permanent identifier, a
<code>pseq_id</code>.  Sequences are never deleted or modified, and the
corresponding <code>pseq_id</code> is never changed. [<a
href="pseq_summary.pl?pseq_id=76">example</a>]

<p>Although sequences in Unison are stored non-redundantly, they came from
many highly redundant databases. Each of those databases typically
provides an accession number, a name, and a description for the sequence.
Unison stores this annotation with each sequence and the date that the
sequence was loaded from each source database and this provides a record
of when a sequence was loaded. Furthermore, each origin is ranked for its
reliability and informative content, and this is used to provide a
heuristic "best annotation" for each sequence as seen in the example.  [<a
href="pseq_paliases.pl?pseq_id=76">example</a>]

<p>After sequences are loaded, a set of reliable sequences is built based
on origin, species, and other properties.  These sequences are subjected
to an array of algorithms whose results are stored.  The predictions
currently include signal sequence, transmembrane prediction, GPI
anchoring, antigenicity, and alignments from BLAST, HMM (Pfam) alignments,
and threading, and many others.  Unison's bookkeeping about which
algorithms have been run (and how) provides a powerful mechanism for
keeping Unison sequences and results up to date [<a
href="pseq_history.pl?pseq_id=76">example</a>].

<p>All precomputed results are linked directly to the <code>pseq_id</code> [<a
href="pseq_features.pl?pseq_id=76">example</a>].  And because precomputed
results are linked to immutable sequences, there's no issue about results
being "stale" with respsect to a changed sequence.  Unison also
distinguishes results by algorighm parameters, and this permits users to
compare several sets of analyses.

<p>Unison integrates many other data sources which are useful in
querying. For example, NCBI's Homologene enables queries to require that a
human putative target also has a homolog in mouse or rat with similar
protein features.  The Structural Classification of Proteins (SCOP),
Patents, Gene Ontology, NCBI taxonomy, and genomic localization and
clustering are also available in Unison.


