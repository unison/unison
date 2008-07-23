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
<h1>Unison In a Nutshell</h1>

<fieldset class="group" style="width: 40%; float: right;">
<legend>
Results Sliced to Order
</legend>

<a class="nofeedback" href="av/results-cube.jpg">
<img style="width: 100%;" src="av/results-cube-med.jpg" alt="[Results Cube]">
</a>

<br>Results in Unison are stored in a sparse cube. The axes of the cube
are 1) distinct sequences, 2) feature types/models, and 3) parameters.
The elements of the cube store structured data appropriate for the
prediction.

</fieldset>


<h2>Goals</h2>

Unison's primary goal is to decrease the challenges associated with asking
both simple and complex questions about protein function and structure.
Unison was designed with three key functional goals in mind:

<dl>
  <dt>Sequence analysis
	<dd>Given a sequence, provide a reliable, up-to-date source of
	features.</dd>

  <dt>Feature-based mining
	<dd>Given a set of protein characteristics, identify matching
	proteins. This is the inverse of sequence analysis.

	<br>Example: <i>Identify Human proteins that contain an immunoglobulin
	(ig) domain by Pfam HMM or structure prediction, a transmembrane (TM)
	domain, and an intracellular immunotyrosine inhibitory motif (ITIM),
	in that order, and that have a mouse ortholog with similar feature
	composition.</i>
  </dd>

  <dt>Hypothesis generation
	<dd>Analyze the function of a set of proteins in terms of their
	constituent features.
	<br>Example: <i>In a set of putative immune signaling proteins, do
	  ITIMs occur in the context of other extracellular domains?</i>
  </dd>
</dl>


<h2>Unique Features</h2>

A few of Unison's distinguishing features are:

<dl>
  <dt>Unison is comprehensive.
	<dd>Unison contains a superset of all database sources from all
	species. This is required to be confident in the completeness of
	queries. Sequences are stored non-redundantly so that you'll never hit
	the same exact sequence twice.
  </dd>

  <dt>Unison integrates diverse protein characteristics.
	<dd> Sequence properties, functional regions, homology, structure
	prediction, and many other predictions are available.  Furthermore,
	Unison allows multiple predictions of the same type with different
	runtime parameters. Because Unison stores digests of the prediction
	results, querying is much more sophisticated and accurate that keyword
	searching.
  </dd>

  <dt>Unison is easy to maintain and update.
	<dd>Unison's release "flow" is nearly fully automated and updates are
	incremental -- only new sequences and new features are computed.
  </dd>

  <dt>Unison incorporates auxiliary data to enable expressive queries
	and rich interpretation of results.
	<dd>These data include Gene Ontology, Structural Classification of
	Proteins, NCBI HomoloGene, NCBI GeneRIF, the Protein Data Bank (PDB),
	and others.
  </dd>

  <dt>Unison is freely available to use and download.
	<dd>The database schema, tools, web pages, and non-proprietary data
	are released under the Academic Free License,
	an <a href="http://www.opensource.org/">OpenSource</a> (TM) approved
	license.  The database and web interface are available for public
	access (query times are limited).
  </dd>
</dl>

<div style="padding: 5px; margin-left: 20px; margin-right: 20px; border: thin solid
red;"><span style="color: red;">*</span> The public version of Unison
contains only public sequences and results of non-proprietary methods.
The entire schema and loading tools are included with the public release;
institutions may load these proprietary data if they wish.</div>

<h2>Take the Tour</h2>
Much more sophisticated queries are possible using the Perl API
and the PostgreSQL interactive SQL interpreter.  Please see
the <a href="tour/">Unison tour</a> for real-life examples
and a demonstration of some of Unison's features.

EOBODY
