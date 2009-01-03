
=head1 NAME

Unison::WWW::AppInfo -- Unison application list

S<$Id: Config.pm 1716 2007-11-05 05:27:08Z reece $>

=cut


package Unison::WWW::PageInfo;

use strict;
use warnings;

use base 'Exporter';
our @EXPORTS = qw();
our @EXPORTS_OK = qw( render_app_list );


sub render_app_list {
  return( 
		 qq(<div class="top">\n<dl>\n), 
		 ( map { format_app_entry($_) } @_ ),
		 qq(</dl>\n</div>\n)
		)
}

sub format_app_entry {
  my $ae = shift;
  return <<EOHTML;
<dt><a href="$ae->{script}">$ae->{name}</a> - $ae->{brief}
<dd>$ae->{descr}
EOHTML
}



1;


# GOAL: (not yet implemented like this)
# app = { script, name, brief, descr, pub, prd }
# appset = { name, url, @app_names, pub, prd }
# warn if @app_names is empty
# main methods: render_appset, render_nav_bar


# STYLE GUIDE:
# {
# 	name => # Short name for this app. Use: tabs and links
#   tab => # tab text (default: name)
# 	script => # basename for the script (in cgi)
#    args => # 'pseq_id=$v->{pseq_id}', etc (optional)
# 	brief => # 3-10 word description of results. Use: tooltips.
#             # No verbs
# 	descr => # paragraph description of app
#    pub => 1 # show in public release (optional; default: no)
#    prd => 1 # show in production release (optional; default: no)
# },



our @search_info = 
  (
   {
	name => 'Aliases',
	script => 'search_alias.pl',
	brief => 'Search for proteins by alias',
	descr => q(Search Unison by protein accession, identifier, or checksum.),
	prd => 1,
	pub => 1,
   },

   {
	name => 'Features',
	script => 'search_features.pl',
	brief => 'Feature-based mining for protein sequecnes',
	descr => qq(Search for protein sequence based on a variety of criteria.),
	pub => 1,
   },

   {
	name => 'Properties',
	script => 'search_properties.pl',
	brief => 'Property-based sequence searches',
	descr => qq(Search for sequences based on sequence source, size, age,
	species, and selected sequence features.),
	prd => 1,
	pub => 1,
   },
  );

our @browse_info = 
  (
   {
	name => 'Sets',
	script => 'browse_sets.pl',
	brief => 'Precomputed sequence sets',
	descr => qq(Browse curated sets of sequences culled from literature or mining.),
	prd => 0,
	pub => 0,
   },

   {
	name => 'Views',
	script => 'browse_views.pl',
	brief => 'Dynamic sequence searches with predefined queries',
	descr => qq(Run "canned queries" to search for sequences using predifined criteria.),
	prd => 1,
	pub => 1,
   },
  );

our @analyze_info = 
  (
   {
	name => 'Summary',
	script => 'pseq_summary.pl',
	args => [ qw(pseq_id) ],
	prd => 1,
	pub => 1,
	brief => 'Protein sequence summary',
	descr => qq(Displays the most pertient and reliable information for a
	specific protein sequence.),
   },

   {
	name => 'Annotations',
	script => 'pseq_annotations.pl',
	args => [ qw(pseq_id) ],
	prd => 1,
	pub => 1,
	brief => 'All annotations for a protein sequence',
	descr => qq(Shows all annotations, accessions and identifiers for a protein
	sequence.),
   },

   {
	name => 'Patents',
	script => 'pseq_patents.pl',
	args => [ qw(pseq_id) ],
	brief => 'Patents "near" a given sequence',
	descr => qq(Displays patents to the specified sequence and those
	within a small sequence similarity "neighborhood".),
	prd => 1,
	pub => 1,
   },

   {
	name => 'Features',
	script => 'pseq_features.pl',
	args => [ qw(pseq_id) ],
	brief => 'Protein sequence features/domains/motifs',
	descr => qq(Displays nearly all precomputed sequence features
	graphically.  Mouseovers and links to underlying data provide
	additional information.),
	prd => 1,
	pub => 1,
   },

   {
	name => 'Similarity',
	script => 'pseq_similarity.pl',
	args => [ qw(pseq_id) ],
	brief => 'Precomputed BLAST results',
	descr => qq(Show precomputed BLAST summary statistics.),
	prd => 1,
	pub => 1,
   },

   {
	name => 'Structures',
	script => 'pseq_structure.pl',
	args => [ qw(pseq_id) ],
	brief => 'Structures and models',
	descr => qq(Displays interactive 3D structures and models for a
	specified sequence using Jmol. Sequence features and SNPs may be
	"painted" on the structure.),
	prd => 1,
	pub => 1,
   },

   {
	name => 'Functions',
	script => 'pseq_functions.pl',
	args => [ qw(pseq_id) ],
	brief => 'Gene Ontology and GeneRIF annotations',
	descr => qq(Display Gene Ontology (GO) annotations and NCBI's
	References Into Function (RIF). Both include links to PubMed
	publications.),
	prd => 1,
	pub => 1,
   },

   {
	name => 'Homologs',
	script => 'pseq_homologs.pl',
	args => [ qw(pseq_id) ],
	brief => 'Homologs from HomoloGene',
	descr => qq(Displays homologs from HomoloGene.),
	prd => 1,
	pub => 1,
   },

   {
	name => 'Interactions',
	script => 'pseq_intx.pl',
	args => [ qw(pseq_id) ],
	brief => 'Protein-Protein interactions',
	descr => qq(),
	#prd => 1,
	#pub => 1,
   },

   {
	name => 'Loci',
	script => 'pseq_loci.pl',
	args => [ qw(pseq_id) ],
	brief => 'Protein-to-Genome alignments',
	descr => qq(Displays the genomic region in which the specified
	sequence, splice forms, and nearby sequences align. Affymetrix and
	Agilent probes are also displayed.),
	prd => 1,
	pub => 1,
   },

   {
	name => 'History',
	script => 'pseq_history.pl',
	args => [ qw(pseq_id) ],
	brief => 'Run history for sequence',
	descr => qq(Unison maintains extensive run histories for each
	sequence.  This tab shows which analyses were run.),
	prd => 1,
	pub => 1,
   },

   {
	name => 'Notes',
	script => 'pseq_notes.pl',
	args => [ qw(pseq_id) ],
	brief => 'Sequence notes',
	descr => qq(),
   },

   {
	name => 'PSSM',
	script => 'pseq_papssm.pl',
	args => [ qw(pseq_id) ],
	brief => 'Precomputed Position-Specific Scoring Matrix alignments',
	descr => qq(Display precomputed Position-Specific Scoring Matrix
	(PSSM) alignments.),
	#prd => 1,
	pub => 1,
   },

   {
	name => 'HMM',
	script => 'pseq_pahmm.pl',
	args => [ qw(pseq_id) ],
	brief => 'Precomputed Hidden Markov Model alignments',
	descr => qq(Display precomputed Hidden Markov Model (HMM)
	alignments. Unison currently contains HMMs only from Pfam. ),
	prd => 1,
	pub => 1,
   },

   {
	name => 'Prospect',
	script => 'pseq_paprospect.pl',
	args => [ qw(pseq_id) ],
	brief => 'Prospect Pro sequence threadings',
	descr => qq(Displays protein threading alignments generated with Prospect Pro.),
	prd => 1,
	#pub => 1,
   },

  );

our @tools_info = 
  (
   {
	name => 'AliAn',
	script => 'alian.pl',
	brief => 'Annotate a set of protein aliases',
	pub => 1,
	prd => 1,
	descr => q(AliAn takes a set of protein accessions and returns a variety of
descriptive information about those accessions.  This is intend for people
with data from mass spectroscopy, pull-downs, or other techniques that
result in sets of protein accessions.),
   },

   { 
	name => 'BabelFish',
	script => 'babelfish.pl',
	pub => 1,
	prd => 1,
	brief => 'Translates protein identifiers',
	descr => qq(
Unison's Babel fish translates essentially any protein sequence
accession/identifier into any other.  Source and destination identfiers
may be from CCDS, Cosmic, Ensembl (most species), FANTOM, Genentech,
Geneseq, HUGE, IPI, MGC, NCBI gi, NCBI RefSeq, PDB, ROUGE, RPS, STRING,
Sugen kinases, UniProtKB/Swiss-Prot, UniProtKB/TrEMBL, and md5
checksums. (This facility is named after <a class="extlink"
target="_blank" href="http://en.wikipedia.org/wiki/Babel_fish">Douglas
Adams' Babel fish</a>.),
)
   },

   {
	name => 'OnTarget',
	script => 'on_target.pl',
	prd => 1,
	pub => 1,
	brief => 'Accuracy assessments for various search methods',
	descr => qq(Compare accuracy of several search methods on predefined
	protein sequence sets.),
   },

   {
	name => 'Framework Search',
	script => 'search_framework.pl',
	#prd => 1,
	pub => 1,
	brief => 'Antibody framework search',
	descr => qq(),
   },

   {
	name => 'Compare Scores',
	script => 'compare_scores.pl',
	#prd => 1,
	#pub => 1,
	brief => 'Compare sequence sets and analysis methods',
	descr => qq(),
   },

   {
	name => 'Compare Methods',
	script => 'compare_methods.pl',
	#prd => 1,
	#pub => 1,
	brief => 'Compare threading methods',
	descr => qq(),
   },
  );


our @unison_info = 
  (
   {
	name => 'Welcome',
	script => 'index.pl',
	brief => '',
	pub => 1,
	prd => 1,
	#descr => ,
   },

   {
	name => 'About',
	script => 'about.pl',
	brief => '',
	pub => 1,
	prd => 1,
	#descr => ,
   },
   {
	name => 'License',
	script => 'license.pl',
	brief => '',
	pub => 1,
	prd => 1,
	#descr => ,
   },

   {
	name => 'Credits',
	script => 'credits.pl',
	brief => '',
	pub => 1,
	prd => 1,
	#descr => ,
   },

   {
	name => 'Contents',
	script => 'contents.pl',
	brief => 'Unison data sources and parameters',
	pub => 1,
	prd => 1,
	#descr => ,
   },

   {
	name => 'Stats',
	script => 'stats.pl',
	# brief =>
	pub => 1,
	#prd => 1,
	# descr => ,
   },

   {
	name => 'Getting It',
	script => 'getting.pl',
	brief => '',
	pub => 1,
	prd => 1,
	descr => 'Obtaining Unison for local installation',
   },

   {
	name => 'Documentation',
	script => 'doc.pl',
	brief => '',
	pub => 1,
	prd => 1,
	descr => '',
   },

   {
	name => 'Shots',
	script => 'shots.pl',
	brief => '',
	pub => 1,
	prd => 1,
	descr => 'Screenshots of the Unison web interface',
   },

#   {
#	name => 'Prefs',
#	script => 'prefs.pl',
#	brief => '',
#	#pub => 1,
#	#prd => 1,
#	#descr => ,
#   },

   {
	name => 'Environment',
	script => 'env.pl',
	brief => '',
	#pub => 1,
	#prd => 1,
	#descr => ,
   },
  );


our @page_sets = 
	(
	 [
	  'Unison',
	  'Information about Unison',
	  'index.pl',
	  \@unison_info
	 ],

	 [
	  'Search',
	  'Text- and Feature-based mining',
	  'search_top.pl',
	  \@search_info
	 ],

	 [
	  'Browse', 
	  'browse curated queries and precomputed sequences sets',
	  'browse_top.pl',
	  \@browse_info
	 ],

	 [
	  'Analyze',
	  'display precomputed analyses for a single protein sequence',
	  'pseq_top.pl',
	  \@analyze_info
	 ],

	 [
	  'Tools',
	  'Miscellaneous services',
	  'tools_top.pl',
	  \@tools_info 
	 ],
	);

