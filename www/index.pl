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
<fieldset class="group" style="width: 50%; float: right;">
<legend>Unison in a Nutshell</legend>
<div style="text-align:">
<a class="nofeedback" href="about.pl">
<img width="100%" src="av/concept-graphic-med.gif" alt="[Concept]">
</a>
<br><a href="about.pl">Learn more about Unison.</a>
</div>
</fieldset>

<span style="font-size: 150%; font-weight: bold;">Welcome to Unison</span>
<p>

Unison is a compendium of protein sequences and extensive precomputed
predictions.  Integration of these and other data within Unison enables
holistic mining of sequences based on protein features, analysis of
individual and sets of sequences, and refinement of hypotheses regarding
the composition of protein families.

<p>Some uses of Unison:

  <dl>
	<dt>Analysis of an Individual Sequence
	  <dd>
		Once you specify a sequence, you can get a gene/protein summary,
		database cross-references, precomputed features, structures and
		structural models with SNPs, and lots more.

		<form method="get" action="pseq_summary.pl" enctype="application/x-www-form-urlencoded">
		  <p>Enter a sequence, sequence alias, md5 checksum: <input type="text" name="q" size="20" maxlength="2000"/><input type="submit" value="go"/>
			<br><i>An alias may be an accession or identifer from any database contained in Unison.</i>
			<br><span class="note"><i>e.g.,</i> <code>TNFA_HUMAN, P01375, <!-- , ENSP00000229681 --> NP_000585.2, IPI00001671.1, 60ada54e69e411bcf6b08e9dacff7a48</code></span>
		</form>
	  </dd>

	  <br>

	<dt>Feature-Based Mining
	  <dd>Unison excels at mining based on precomputed sequences features.
		You may search for sequences
		by <a href="search_properties.pl">specifying
		features</a>, <a href="on_target.pl">exploring curated
		models and sequence sets</a>,
		or <a href="browse_views.pl">browsing predefined, dynamic
		queries</a>.
	  </dd>

	  <br>

	<dt>Tools

	  <dd>Unison provides two web tools that are intended for users with
		high-throughput experimental data.  <a
		href="babelfish.pl">BabelFish</a> translates a list of protein
		aliases protein aliases (accessions, identifiers, or checksums)
		into aliases for several target databases based on sequence
		identity.  <a href="alian.pl">AliAn</a> provides a annotations,
		domains, locus, GO and other annotations for a list of protein
		aliases.

  </dl>

EOBODY
