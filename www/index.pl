#!/usr/bin/perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison;
use Unison::Exceptions;
use Unison::WWW::Page;


my $p = new Unison::WWW::Page();

print $p->render('Welcome', <<EOBODY);
<fieldset class="group" style="width: 40%; float: right;">
<legend>Unison in a Nutshell</legend>
Unison integrates many types of protein predictions to enable holistic
mining of sequences based on protein features, synthesis of these
predictions for the analysis of individual and sets of sequences, and
refinement of hypotheses regarding the composition of protein families.
<div style="text-align:">
<a class="nofeedback" href="about.pl">
<img width="100%" src="av/concept-graphic-med.jpg" alt="[Concept]">
</a>
<br><a href="about.html">Learn more about Unison.</a>
</div>
</fieldset>

<span style="font-size: 150%; font-weight: bold;">Welcome to Unison</span>
<p>


Some Uses of Unison:
  <dl>
	<dt>Analysis of an Individual Sequence
	  <dd>
		Once you specify a sequence, you can get a gene/protein summary,
		database cross-references, precomputed features, structures and
		structural models with SNPs, and lots more.

		<form method="get" action="pseq_summary.pl" enctype="application/x-www-form-urlencoded">
		  <p>Enter a sequence, sequence alias, md5 checksum: <input type="text" name="q" size="20" maxlength="2000"/><input type="submit" value="go"/>
			<br><i>An alias may be an accession or identifer from any database contained in Unison.</i>
			<br><i>e.g.,</i> <code>TNFA_HUMAN, P01375, <!-- , ENSP00000229681 --> NP_000585.2, IPI00001671.1, 60ada54e69e411bcf6b08e9dacff7a48</code>
		</form>
	  </dd>

	  <br>

	<dt>Feature-Based Mining
	  <dd>Unison excels at mining based on precomputed sequences features.
		You may search for sequences
		by <a href="search_properties.pl">specifying
		features</a>, <a href="search_sets.pl">exploring curated
		models and sequence sets</a>,
		or <a href="browse_views.pl">browsing predefined, dynamic
		queries</a>.
	  </dd>

	  <br>

	<dt>Tools
	  <dd>Unison provides two tools that are intended for users who have
		protein aliases (accessions, identifiers, or checksums) from
		high-throughput experimental methods.
		<a href="babelfish.pl">BabelFish</a> translates a list of
	  protein aliases into aliases for several target databases based on
	  sequence identity.  <a href="alian.pl">AliAn</a> provides a
	  annotations, domains, locus, GO and other annotations for a list of
	  protein aliases.
  </dl>

EOBODY
