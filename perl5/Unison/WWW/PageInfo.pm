
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


our @tools_info = 
  (
   {
	name => 'AliAn',
	script => 'alias_annotation.pl',
	brief => 'Annotate a set of protein aliases',
	pub => 1,
	#prd => 1,
	descr => q(AliAn takes a set of protein accessions and returns a variety of
descriptive information about those accessions.  This is intend for people
with data from mass spectroscopy, pull-downs, or other techniques that
result in sets of protein accessions.),
   },

   { 
	name => 'BabelFish',
	script => 'babelfish.pl',
	pub => 1,
	#prd => 1,
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


our @search_info = 
  (
   {
	name => 'Alias Search',
	script => 'search_alias.pl',
	brief => 'Search for proteins by alias',
	descr => q(Search Unison by protein accession, identifier, or checksum.),
	prd => 1,
	pub => 1,
   },

   {
	name => 'Feature Search',
	script => 'search_features.pl',
	brief => 'Search for proteins by features',
	descr => qq(),
	pub => 1,
   },

   {
	name => 'Property Search',
	script => 'search_properties.pl',
	brief => '',
	descr => qq(),
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
	name => 'Aliases',
	script => 'pseq_paliases.pl',
	args => [ qw(pseq_id) ],
	prd => 1,
	pub => 1,
	brief => 'All aliases for a protein sequence',
	descr => qq(Shows all aliases (accessions and identifiers) for a protein
	sequence.),
   },

   {
	name => 'Patents',
	script => 'pseq_patents.pl',
	args => [ qw(pseq_id) ],
	brief => 'Patents "near" a given sequence',
	descr => qq(),
	prd => 1,
	pub => 1,
   },

   {
	name => 'Features',
	script => 'pseq_features.pl',
	args => [ qw(pseq_id) ],
	brief => 'Protein sequence features/domains/motifs',
	descr => qq(),
	prd => 1,
	pub => 1,
   },

   {
	name => 'BLAST',
	script => 'pseq_blast.pl',
	args => [ qw(pseq_id) ],
	brief => 'Precomputed BLAST results',
	descr => qq(),
	prd => 1,
	pub => 1,
   },

   {
	name => 'PSSM',
	script => 'pseq_papssm.pl',
	args => [ qw(pseq_id) ],
	brief => 'Precomputed Position-Specific Scoring Matrix alignments',
	descr => qq(),
	#prd => 1,
	pub => 1,
   },

   {
	name => 'HMM',
	script => 'pseq_pahmm.pl',
	args => [ qw(pseq_id) ],
	brief => 'Precomputed Hidden Markov Model alignments',
	descr => qq(),
	prd => 1,
	pub => 1,
   },

   {
	name => 'Prospect',
	script => 'pseq_paprospect.pl',
	args => [ qw(pseq_id) ],
	brief => 'Prospect Pro sequence threadings',
	descr => qq(),
	prd => 1,
	#pub => 1,
   },

   {
	name => 'Structures',
	script => 'pseq_structure.pl',
	args => [ qw(pseq_id) ],
	brief => 'Structures and models',
	descr => qq(),
	prd => 1,
	pub => 1,
   },

   {
	name => 'Functions',
	script => 'pseq_functions.pl',
	args => [ qw(pseq_id) ],
	brief => 'Gene Ontology and GeneRIF annotations',
	descr => qq(),
	prd => 1,
	pub => 1,
   },

   {
	name => 'Homologs',
	script => 'pseq_homologs.pl',
	args => [ qw(pseq_id) ],
	brief => 'Homologs from HomoloGene',
	descr => qq(),
	prd => 1,
	pub => 1,
   },

   {
	name => 'Interactions',
	script => 'pseq_intx.pl',
	args => [ qw(pseq_id) ],
	brief => '',
	descr => qq(),
	#prd => 1,
	#pub => 1,
   },

   {
	name => 'Loci',
	script => 'pseq_loci.pl',
	args => [ qw(pseq_id) ],
	brief => 'Protein-to-Genome alignments',
	descr => qq(),
	prd => 1,
	pub => 1,
   },

   {
	name => 'History',
	script => 'pseq_history.pl',
	args => [ qw(pseq_id) ],
	brief => 'Run history for sequence',
	descr => qq(),
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

  );

our @browse_info = 
  (
   {
	name => 'Sets',
	script => 'browse_sets.pl',
	brief => 'Precomputed sequence sets',
	descr => qq(),
	prd => 1,
	pub => 1,
   },

   {
	name => 'Views',
	script => 'browse_views.pl',
	brief => 'Dynamic sequence searches with predifined queries',
	descr => qq(),
	prd => 1,
	pub => 1,
   },
  );
