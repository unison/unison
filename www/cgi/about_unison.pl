#!/usr/bin/env perl

use strict;
use warnings;
use CGI( -debug );
use Data::Dumper;
BEGIN
  {
  if (exists $ENV{SCRIPT_FILENAME})
	{ ($ENV{PWD}) = $ENV{SCRIPT_FILENAME} =~ m%^(.*/)%; }
  }
use lib $ENV{PWD}."/../perl5";
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();


my $blurb = <<EOT;
<p>Unison is a database of non-redundant protein sequences and precomputed
results on those sequences.  Because many results have been precomputed,
Unison enables answers to hypothesis that might have been previously
impractical.

<p>The sequences in Unison are culled from numerous sources and included
both well-annotated sequences (<i>e.g.,</i> from Swiss-Prot) and
speculative sequences (<i>e.g.,</i> gene transcript predictions and raw
6-frame translations).  Sequences in Unison have a permanent, stable
identifier (`pseq_id').  Once in Unison, a sequence may not be modified
(of course, a modified sequence may be added).  Although sequences are
stored uniquely, information about the sequence's origin and accession are
preserved [<a href="pseq_paliases.pl?pseq_id=76">example</a>].

<p>Precomputed results are linked directly to the pseq_id [<a
href="pseq_features.pl?pseq_id=76">example</a>].  Because sequences are
immutable, users need not worry about the possibility that precomputed
results become obsolete.  Because sequences are non-redundant, the results
are computed only once.

<p>Perhaps the most convenient feature of Unison is that new sequence
sources may be loaded very quickly, and only the new or changed sequences
are actually loaded.  These sequences are timestamped to facilitate
identifying which sequences need to be analyzed.

EOT

print $p->render("About Unison",
				 $blurb,
				);
