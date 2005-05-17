=head1 NAME

Unison::WWW::Page -- Unison web page framework

S<$Id: Page.pm,v 1.47 2005/05/13 19:02:05 rkh Exp $>

=head1 SYNOPSIS

 use Unison::WWW::Page;
 my $p = new Unison::WWW::Page;

=head1 DESCRIPTION

B<Unison::WWW::Page> provides a class for consistent rendering of Unison
web pages. It's simple and not powerful.

=cut


package Unison::WWW::Page;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use warnings;

use base Exporter;
use CGI qw( -debug -nosticky -newstyle_urls);
push(@ISA, 'CGI');
#BEGIN { (-t 0) || eval "use CGI::Carp qw(fatalsToBrowser)" }

use Unison;
use Unison::Exceptions;
use Unison::WWW::utilities qw( text_wrap );
use File::Temp;
use Error qw(:try);

#XXX: WARNING: strict must be last, unsure why, and this bothers me
#use strict;


sub _page_connect ($);
sub _infer_pseq_id ($);
sub _make_temp_dir ();
sub _cleanup_temp($);

our $infer_pseq_id = 0;



=pod

=head1 PUBLIC METHODS

=over

=cut


######################################################################
## new

=pod

=item B<< ::new( key=>value ) >>

=cut

sub new {
  my $class = shift;
  my $self = $class->SUPER::new( @_ );
  $self->{starttime} = time;
  my $v = $self->Vars();
  $v->{debug} = 0 unless defined $v->{debug};


  try {
	_page_connect($self);
  }	catch Unison::Exception with {
	my $ex_text = ( defined $_[0] ? 
					CGI::escapeHTML($_[0]) :
					'no exception information' );
	my $env = join('', map( { "<br><code>$_: ".(defined $ENV{$_} ? 
												$ENV{$_}
												:'<i>undef</i>')."</code>\n" }
							qw(REMOTE_USER KRB5CCNAME) ));

	__PACKAGE__->die('Unison Connection Failed', 
					 '<pre>'.$ex_text.'</pre>',
					 '<p>',
					 '<hr>Kerberos and user information:',
					 $env
					);
  };


  $self->{userprefs} = $self->{unison}->get_userprefs();
  $self->{readonly} = 1;
  $self->{js_tags} = [{-languange => 'JAVASCRIPT', -src => '../js/ToolTips.js'},
					  {-languange => 'JAVASCRIPT', -src => '../js/DOM_Fixes.js'}];

  if (not exists $v->{pseq_id} and $infer_pseq_id) {
	my @st = grep {exists $v->{$_}} qw(q pseq_id seq md5 alias);
	if (@st > 1) {
	  $self->die("please don't provide more than one search term",
				 sprintf('You provided criteria for %d terms (%s)',
						 $#st+1, join(',',@st) ));
	}
	$v->{pseq_id} = _infer_pseq_id($self);
	if (not defined $v->{pseq_id}) {
	  $self->die("couldn't infer pseq_id from arguments");
	}

	# hereafter, we don't want these polluting our variables
	delete $v->{'q'};
	delete $v->{alias};
	delete $v->{md5};
	delete $v->{seq};
  }

  # if we've made it this far, we'll eventually get a page out
  $self->start_html;

  return $self;
}


######################################################################
## Vars()

=pod

=item B<< $p->Vars( C<> ) >>

return a hash of page variables.  This works exactly like the CGI::Vars()
method, hence its name, except that the result is cached so that repeated
calls are trivial.

=cut

sub Vars {
  my $self = shift;
  return unless ref $self;
  if (not exists $self->{Vars}) {
	$self->{Vars} = $self->SUPER::Vars();
  }
  return $self->{Vars};
}



######################################################################
## tempfile()

=pod

=item B<< ($fh,$fn,$urn) = $p->tempfile( C<vars> ) >>

Generates a tempfile with a filehandle, filename, and urn. This function,
and only this function, should be used for all temporary files which need
to be passed back to a browser. The created file will persist after the
CGI exits and be cleaned up later.

The file is created by File::Temp::tempfile, and the options are
identical. HOWEVER, the DIR=> argument may not be overridden.

undef is returned on failure.  It should throw an exception, but doesn't
yet.

=cut

sub tempfile {
  my $self = shift;
  $self->_cleanup_temp() if rand(0)<=0.20;	# try cleanup 20% of the time
  $self->_make_temp_dir(); 					# no return if failure
  my %opts = (								# order is important:
			  UNLINK=>0, 					# - items before @_ are defaults
			  @_,							# - items after @_ override any
			  DIR=>$self->{tmpdir}			#   calling arguments
			 );

  if ( my ($fh,$fn) = File::Temp::tempfile( %opts ) ) {
	my ($urn) = $fn =~ m/^$self->{tmproot}(\/.+)/;
	return ($fh,$fn,$urn);
  }

  return undef;
}



######################################################################
## ensure_required_params()

=pod

=item B<< $p->ensure_required_params( C<vars> ) >>

Ensure that the named variables were provided in the HTML GET or POST
request. If not, the page C<dies> (which see) with an appropriate error.

=cut

sub ensure_required_params {
  my $self = shift;
  my @undefd = grep { not defined $self->param($_) or $self->param($_) eq '' } @_;
  return 0 unless @undefd;
  $self->die('Missing parameters',
		  '<br>The follow parameters were missing:',
		  '<br>&nbsp;&nbsp;&nbsp; <code>' . join(', ', @undefd) . '</code>' );
  # doesn't return
}


######################################################################
## header()

=pod

=item B<< $p->header() >>

returns the HTML header

=cut

sub header {
  my $self = shift;
  return '' if ref $self and $self->{already_did_header}++;
  return $self->SUPER::header();
}

######################################################################
## add_html()

=pod

=item B<< $p->add_html() >>

adds HTML tags

=cut
sub add_html {
  my $self = shift;
  my (@params) = @_;
  foreach my $i (0..$#params) {
    push @{$self->{js_tags}}, $params[$i+1]  if ($params[$i] eq '-script' and ref($params[$i+1]) eq 'HASH');
  }
}

######################################################################
## start_html()

=pod

=item B<< $p->start_html( @_ ) >>

returns a Unison-specific preamble for a web page.

=cut

sub start_html {
  my $self = shift;

  return $self->SUPER::start_html
	( @_,
	  -head => [
				$self->Link({-rel => 'shortcut icon',
							 -href => '../av/favicon.png'})
			   ],
	  -style => { -src => ['../styles/unison.css', '../styles/ToolTips.css'] },
	  -target => '_top',
	  -onload => 'javascript:{ initToolTips(); }',
	  -script => $self->{js_tags},
	);
}


######################################################################
## render()

=pod

=item B<< $p->render( C<title>, C<body elems, ...> ) >>

Generates a Unison web page with title given C<title> and with the
page-specific content provided by an array of C<body elems>.

=cut


sub render {
  my $self = shift;
  my $title = shift;

  my $cnav = '';
  my $elapsed = '';

  if (ref $self and defined $self->{unison} and $self->{unison}->is_open()) {
	if (dev_instance()) {
	  $cnav .= '<center><span style="background-color: red"><b>development</b></span></center>';
	}
	if (not $self->{readonly}) {
	  $cnav .= '<center><span style="background-color: lightgreen"><b>writable</b></span></center>';
	}
	$cnav .= join('<p>',
				 map( {"<b>$_->[0]:</b><br>&nbsp;&nbsp;$_->[1]"}
					  # key-value pairs:
					  (map {[$_ , (defined $self->{unison}->{$_} ? $self->{unison}->{$_} : 'unknown')]}
					   qw(username host dbname)),
					  ['db<br>release',
					   $self->{unison}->selectrow_array
					   ('select value::date from meta where key=\'release timestamp\'') || ''],
					  ['API<br>release', $Unison::RELEASE],
					  ['WWW<br>release', $Unison::WWW::RELEASE]
					  ),
				 ( dev_instance() ? $self->warn('This is a development
		    		version of Unison. Pages may be unstable and features may change.
		    		Do not bookmark this page.') : ''),
				);
	$elapsed = 'page generated in ' . (time - $self->{starttime}) . ' seconds';
  }

  return ($self->header(),

		  $self->start_html(-title=>"Unison: $title"), "\n\n\n",

		  '<table class="page">', "\n",

		  "\n<!-- ========== begin banner bar ========== -->\n",
		  '<tr>', "\n",
		  '  <td class="logo" width="10%">',
		  '<a href="about_unison.pl"><img tooltip="Unison home page" width="90%" class="logo" src="../av/unison.gif"></a>',
		  '</td>',"\n",
		  '  <td class="navbar" padding=0>', $self->_navbar(), '</td>', "\n",
		  '</tr>', "\n",
		  "<!-- ========== end banner bar ========== -->\n",

		  '<tr>', "\n",
		  "\n<!-- ========== begin subnav content ========== -->\n",
		  '  <td class="cnav">', $cnav, '</td>', "\n",
		  "\n<!-- ========== end subnav content ========== -->\n",

		  "\n<!-- ========== begin page content ========== -->\n",
		  '  <td class="body">', "\n",
		  "  <b>$title</b><br>", "\n", 
		  '  ', @_, "\n",
		  '  </td>', "\n",
		  "\n<!-- ========== end page content ========== -->\n",
		  '</tr>', "\n",

		  "\n<!-- ========== begin footer ========== -->\n",
		  '<tr>', "\n",
		  '  <td class="logo"><a href="http://www.postgresql.org/"><img class="logo" ',
		        ' src="../av/poweredby_postgresql.gif"></a></td>', "\n",
		  '  <td class="footer">',
		  "     Please contact <a href=\"http://gwiz/local-bin/empshow.cgi?empkey=26599\">Reece Hart</a> with suggestions or problems\n",
		  "     <br>$elapsed\n",
		  (defined $self->{footer} ? map {"     <br>$_\n"} @{$self->{footer}} : ''),
		  "  </td>\n",
		  "</tr>\n",
		  "\n<!-- ========== end footer ========== -->\n",

		  '</table>', "\n",

		  "\n", $self->end_html(),"\n"
		 );
}


######################################################################
## group()

=pod

=item B<< $p->group( C<> ) >>

=cut

sub group {
  my $self = shift;
  my $name = shift;
  my $ctl = '';
  # for backward compatibility, $name may be a scalar
  # to introduce a new feature, I unforunately needed to permit
  # $name to be an array ref, in which case it is expected to contain
  # the group name (as before) and HTML to be right justified on the same tr
  if (ref $name eq 'ARRAY') {
	($name,$ctl) = @$name;
  }
  $name =~ s/\s+/\&nbsp;/g unless $name =~ m/<.+>/;	# don't nbsp-ize HTML
  return("<table class=\"group\">\n",
	   "<tr><th class=\"grouptag\">$name</th><th valign=\"middle\" align=\"right\">$ctl</th></tr>\n",
	   "<tr><td colspan=\"2\">\n",@_,"\n</td></tr>\n",
	   "</table>\n");
}


######################################################################
## make_url()

=pod

=item B<< $p->make_url( C<addl vars, ...> ) >>

build a url from the CGI query object with values from a specified
variable list

=cut

sub make_url {
  my $self = shift;
  my $vars = $self->Vars();
  my $addlvars = ref $_[0] ? shift : {};
  my %vars = (%$vars, %$addlvars);

  my @keys;
  if (@_) {									# specified query vars only
	my %keys = map { $_=>1 } @_, keys %$addlvars;
	@keys = sort keys %keys;
  } else {									# or default is all vars
	@keys = sort keys %vars;
  }

  my $url = $self->url(-relative=>1);

  my $qargs = join( ';', map {"$_=$vars{$_}"} grep {defined $vars{$_}} @keys);
  $url .= '?' . $qargs if $qargs ne '';

  return $url;
}



=pod

=head1 PUBLIC METHODS FOR STANDARDIZED FORMATTING

=over

=cut


######################################################################
## sql()

=pod

=item B<< $p->sql( C<text> ) >>

format C<text> as a SQL block on the web page

=cut

sub sql {
  my $self = shift;
  return '' unless $self->{userprefs}->{'show_sql'};
  return( "\n", '<p><div class="sql"><b>SQL query:</b> ',
		  (map {CGI::escapeHTML($_)} text_wrap(@_)),
		  '</div>', "\n" );
}


######################################################################
## tip()

=pod

=item B<< $p->tip( C<text> ) >>

format C<text> as a "tip" block on the web page

=cut

sub tip {
  my $self = shift;
  return '' unless $self->{userprefs}->{'show_tips'};
  return( "\n",'<p><div class="tip"><b>Tip:</b> ', @_, '</div>', "\n");
}


######################################################################
## tooltip()

=pod

=item B<< $p->tooltip( C<text>, C<tip> ) >>

Format C<tip> as a "tooltip" which will appear when the mouse is over
C<text>.

=cut

sub tooltip {
  my $self = shift;
  my ($text,$tooltip) = @_;
  $tooltip =~ s/\s+/ /g;
  return( '<span class="tipped" tooltip="'
		  . CGI::escapeHTML($tooltip)
		  . '">'
		  . CGI::escapeHTML($text)
		  . '</span>' );
}


######################################################################
## warn()

=pod

=item B<< $p->warn( C<text>, ... ) >>

Formats arguments as a warning block. This is intended to be used inline
with other Unison::Page "body" elements. 

=cut

sub warn {
  my $self = shift;
  return( "\n",'<p><div class="warning"><b>Warning:</b> ', 
		  @_, '</div>', "\n" );
}


######################################################################
## die()

=pod

=item B<< $p->die( C<text> ) >>

Returns a Unison error page with C<text>.  This returns a new page and
exits with status 0 (so that webservers will actually return the page).

=cut

sub die {
  my $self = shift;
  my $t = shift;
  print $self->render( "Error: $t",
					'<p><div class="warning">',
					'<b>Error:</b> ', $t, '<br>',
					join(' ',@_), 
					'</div>', "\n" );
  exit(0);
}


######################################################################
## best_annotation()

=pod

=item B<< $p->best_annotation( C<pseq_id> ) >>

render the best_annotation of the sequence identified by pseq_id
C<pseq_id>

=cut

sub best_annotation {
  my $self = shift;
  my $pseq_id = shift;

  return( $self->tooltip( '"best" annotation', 'Best annotations are
					   a guess about the most informative and reliable
					   annotation for this sequence from all source
					   databases. Click the Aliases tab to see all
					   annotations' ),
		  ': ',
		  $self->{unison}->best_annotation($pseq_id,1) );
}


######################################################################
## add_footer_lines()

=pod

=item B<< $p->add_footer_lines( C<lines, ...> ) >>

adds the specified lines to the footer

=cut

sub add_footer_lines {
  my $self = shift;
  push(@{$self->{footer}}, @_);
}


######################################################################
## debug()

=pod

=item B<< $p->debug( C<message> ) >>

render C<message> in a special debugging block

=cut

sub debug {
  my $self = shift;
  print $self->render("debug: $_[0]",'<span class="debug">',
				   join('<br>',@_),'</span>');
}

######################################################################
## import

sub import {
  my $self = shift;
  for (@_) {
	$infer_pseq_id=1 if ($_ eq 'infer_pseq_id');
  }
}

######################################################################
## dev_instance

=pod

=item B<< ::dev_instance() >>

Return true if this is NOT on the production port (80) OR if the page is
being served by a user development directory

=cut
sub dev_instance {
  my $self = shift;
  return ( (exists $ENV{SERVER_PORT} and $ENV{SERVER_PORT}!=80)
		   or (exists $ENV{REQUEST_URI} and $ENV{REQUEST_URI} =~ m%/~%) );
}






######################################################################

=pod

=head1 INTERNAL METHODS

These methods typically begin with one underscore (e.g., _internal_method).

=over

=cut


######################################################################
## _page_connect

sub _page_connect ($) {
  my $self = shift;
  my $v = $self->Vars();

  # If dbname is not explicitly set, set it based on SERVER_PORT
  # SERVER_PORT is always set, except when debugging from the command line
  if (not exists $v->{dbname}) {
    $v->{dbname} = 'csb';
    if (defined $ENV{SERVER_PORT}) {
      if    ($ENV{SERVER_PORT} == 8040)  { $v->{dbname} = 'csb-stage' }
      elsif ($ENV{SERVER_PORT} == 8080)  { $v->{dbname} = 'csb-dev' }
	}
  }

  # If KRB5CCNAME is set, we're doing kerberos authentication.
  if (exists $ENV{KRB5CCNAME}) {
	$v->{username} = $ENV{REMOTE_USER} 		# from webserver...
	                 || `/usr/bin/id -un`;	# ... or running on command line
	$v->{username} =~ s/@.+//;				# strip domain name
  }

  # Attempt a PUBLIC connection unless username is set.
  $v->{username} = 'PUBLIC' unless defined $v->{username};

  # host "csb" is most likely ("csb-dev" may exist)
  $v->{host} = 'csb' unless defined $v->{host};

  # NOTE: password=>undef works for PUBLIC and krb auth
  $self->{unison} = new Unison( username => $v->{username},
								password => undef,
								host => $v->{host},
								dbname => $v->{dbname} );

  # Set PG vars so that spawned apps connect to the same database
  # This will only work for kerberos authentication
  $ENV{PGHOST} = $v->{host};
  $ENV{PGUSER} = $v->{username};
  $ENV{PGDATABASE} = $v->{dbname};

  return $self->{unison};
}



######################################################################
## _infer_pseq_id

=pod

=item B<< $p->_infer_pseq_id() >>

=cut

sub _infer_pseq_id ($) {
  # Most pages should refer to sequences by pseq_id. If pseq_id isn't
  # defined, then we attempt to infer it from given 'seq', 'md5', or
  # 'alias' (in that order).  Furthermore, if none of those are defined
  # but 'q' is, then we heuristically attempt to guess whether q is a
  # pseq_id, md5, or alias.  This is an effort to facilitate 'just do the
  # right thing' lookups (e.g., from a browswer toolbar)

  my $self = shift;
  my $v = $self->Vars();

  if ( exists $v->{'q'} ) {
	my $q = $v->{'q'};

	if ($q !~ m/\D/)				{ return $q; };

	if (length($q)==32 and $q!~m/[^0-9a-f]/i) {
	  $v->{md5} = $q;
	} else {
	  $v->{alias} = $q;
	}
  }


  if (exists $v->{seq}) {
	my $pseq_id = $self->{unison}->pseq_id_by_sequence( $v->{seq} );
	if (not defined $pseq_id) {
	  $self->die('sequence not found',
				 'The sequence you provided wasn\'t found in Unison.');
	}
	return $pseq_id;
  }


  if (exists $v->{md5}) {
	my (@ids) = $self->{unison}->pseq_id_by_md5( $v->{md5} );
	if ($#ids == -1) {
	  $self->die('md5 checksum not found',
				 'The md5 checksum you provided wasn\'t found in Unison.');
	} elsif ($#ids > 0) {
	  # md5 collision! (hasn't happened yet and I don't expect it), but just in case...
	  $self->die('md5 collision!',
				 'The md5 checksum you provided corresponds to more than one sequence.');
	}
	return $ids[0];
  }

  if (exists $v->{alias}) {
	my (@ids) = $self->{unison}->get_pseq_id_from_alias( $v->{alias} );
	if ($#ids == -1) {
	  $self->die('alias not found',
				 'The alias you provided wasn\'t found in Unison (case insensitive).');
	} elsif ($#ids > 0) {
	  print CGI::redirect("search_by_alias.pl?alias=$v->{alias}");
	  exit(0);
	}
	return $ids[0];
  }

  $self->die('Please specify sequence', <<EOT );
The page you requested requires you to specify a sequence.
<p>You may wish to <a href="search_by_alias.pl">search for a sequence by name</a>.
EOT

  # NO RETURN
}


######################################################################
## _navbar

sub _navbar {
  my $self = shift;
  my $v = $self->Vars() || {};
  my $pseq_id = exists $v->{pseq_id} ? "pseq_id=$v->{pseq_id}" : '';
  my @navs =
	## format: @navs = ( menu, menu, ... );
	## where each menu is
	## [ [ name, tooltip ],
	##   [ sub1, tooltip1, script1, args1 ],
	##   [ sub2, tooltip2, script2, args2 ],
	##   ...
	## ]
	(
	 [	# About menu
	  ['About', 		'about Unison'],
	  ['Unison', 		'about unison', 					'about_unison.pl'],
	  ['Credits', 		'thanks, ma!',						'about_credits.pl'],
	  ['Contents', 		'show unison meta information', 	'about_contents.pl'],
	  ['Env', 			'Environment info', 				'about_env.pl'],
	  ['Prefs',			'User Prefs', 						'about_prefs.pl'],
	 ],

	 [	# Sequence menu
	  ['Protein Analysis', 'display precomputed analyses for a single sequence'],
	  ['Summary', 		'summary of sequence information', 	'pseq_summary.pl', 	$pseq_id ],
	  ['Aliases', 		'all aliases of this sequence', 	'pseq_paliases.pl', $pseq_id ],
	  ['Patents', 		'patents on this sequence', 		'pseq_patents.pl', 	$pseq_id ],
	  ['Features',		'sequences features', 				'pseq_features.pl', $pseq_id ],
	  ['Structure',		'structural features', 				'pseq_structure.pl', $pseq_id ],
	  ['BLAST', 		'BLAST-related sequences', 			'pseq_blast.pl', 	$pseq_id ],
	  ['Prospect2', 	'Prospect2 threadings', 			'pseq_paprospect2.pl', $pseq_id],
	  ['HMM', 			'Hidden Markov Model alignments', 	'pseq_pahmm.pl', 	$pseq_id ],
	  ['PSSM',			'PSSM alignments', 					'pseq_papssm.pl', 	$pseq_id ],
	  ['Interactions',	'Protein-Protein Interactions', 	'pseq_intx.pl',		$pseq_id ],
	  ['Loci',			'genomic localization', 			'pseq_loci.pl', 	$pseq_id ],
	  ['Notes',			'user notes on this sequence',		'pseq_notes.pl', 	$pseq_id ],
	  ['History',		'run history',						'pseq_history.pl', 	$pseq_id ],
	 ],

	 [	# Browse menu
	  ['Browse', 'browse curated sets of sequences (unimplemented)'],
	  ['Sets', 'browse <i>precomputed</i> sets of proteins', 'browse_sets.pl'],
	  ['Views', 'browse dynamic queries of protein sequences', 'browse_views.pl'],
	  # ['SCOP', undef, 'browse_scop.pl'],
	  # ['Origins', undef, 'browse_origins.pl']
	 ],

	 [	# Search menu
	  ['Search', 		'search for sequences which match criteria' ],
	  ['By Alias',		'search for sequences by alias/name/accession', 'search_by_alias.pl'],
	  ['By Properties',	'mine for sequences based on properties', 'search_by_properties.pl'],
	  ['Compare Sets',	'compare a set of sequences to a set of models ', 'search_sets.pl'],
	  ['Framework',    	'search for sequences matching a set of sequence regions', 'search_framework.pl'],
	 ],

	 [	# Assess menu
	  ['Assess', 		'compare sequence sets and analysis methods'],
	  ['Scores', 		'compare scoring systems',			'compare_scores.pl'],
	  ['Methods', 		'compare threading methods',		'compare_methods.pl'],
	 ],

	  # empty list forces right-justification of subsequent menus
	  #[ [ '' ]  ],

	  #[
	  # ['Help', 		'Help using Unison'],
	  # ['Tips',			'Tips', 						'about_prefs.pl'],
	  #],

	  #[ # run menu
	  # ['Run', 'run analyses on sequences for which precomputed results aren\'t available'],
	  # ['BLAST', undef, 'run_blast.pl'],
	  # ['Pfam', undef, 'run_pfam.pl']
	  #],

	  #[ # special menu
	  # ['Special', 'special projects'],
	  # ['Preferences', 'user preferences']
	  # ['UNQ', 'UNQ browsing']
	  #],

	  #[ # admin menu
	  # ['Admin', 'Unison administration'],
	  # ['Aliases', 'update aliases', 'pseq_paliases.pl', 'upd=1']
	  #],

	);

  my ($navi,$subnavi) = $self->_find_nav_ids(@navs);
  my $rv = '';
  # MISFEATURE: undefined navi may occur (eg genome_features) and this causes
  # the navbar to be omitted.
  if (defined $navi) {
	$rv = "\n  <table    class=\"nav\" width=\"100%\">"
		  . "\n    <tr>" . _make_navrow($navi, map {[ @{$_->[0]}, @{$_->[1]}[2,3]]} @navs) . '</tr>'
		  . "\n    <tr>" 
		  . ($navi==0      ? '' : sprintf('<td colspan=%d></td>',$navi))
		  . '<td align="center"><img src="../av/v.gif"></td>'
		  . ($navi==$#navs ? '' : sprintf('<td colspan=%d></td>',$#navs-$navi))
		  . '</tr>'
		  . "\n  </table>\n";

	my @nav = @{$navs[$navi]};
	shift @nav;				# menu header is first item; menu items remain
	$rv .= "\n  <table class=\"subnav\" width=\"100%\">" 
	  . '<tr>' . _make_navrow($subnavi, @nav) . '</tr>'
	  . "</table>\n";
  }
  return $rv;
}


sub _find_nav_ids {
  my $self = shift;
  my @navs = @_;
  my $script = $self->url(-relative => 1);
  $script =~ s/\?$//;
  for(my $i=0; $i<=$#navs; $i++) {
	my @snavs = @{$navs[$i]};
	shift @snavs;							# menu title
	for(my $j=0; $j<=$#snavs; $j++) {
	  return($i,$j) if (defined $snavs[$j]->[2] and $snavs[$j]->[2] eq $script);
	}}
  return;
  }




sub _make_navrow {
  # makes one row of the navbar as an array of <td>...</td> objects
  # $sel is which is selected, and may be undef
  # @tu = array ref of [text,tooltip,url,params]
  my ($sel,@tu) = @_;
  my $spacer = '<td width="%80">&nbsp;</td>';
  my @nav = ();
  for(my $i=0; $i<=$#tu; $i++) {
	my ($text,$tooltip,$url,$params) = @{$tu[$i]};
	if ($text eq '') {
	  push(@nav, $spacer);
	  $spacer = '';
	  next;
	}

	$text =~ s/ /&nbsp;/g;					# make tab headings non-breaking
	$tooltip = defined $tooltip ? ' tooltip="'.$tooltip.'"' : '';
	$url .= "?$params" if defined $params;
	my $cl = 'unselected';
	if (defined $sel and $sel == $i) {
	  $cl = 'selected';
	  $url = undef;
	}
	push(@nav, "<td class=\"$cl\">"
		 . (defined $url ? "<a href=\"$url\"$tooltip>$text</a>" : "<span$tooltip>$text</span>")
		 . "</td>" );
  }
  return( join('', @nav) . $spacer );
}

sub _make_temp_dir () {
  # set the temporary file directory and ensure that it exists
  # tmp files will be created in DOCUMENT_ROOT/tmp/<date> if called
  # as a CGI, or in /tmp/ if run on the command line 
  # sets: $self->{tmproot} as the root of the tmp directory
  # 		(either /tmp/ or DOCUMENT_ROOT/tmp/)
  #       $self->{tmpuri} as the URI-portion of the temporary file
  #         directory which may be used in URLs
  #       $self->{tmpdir} is the full local path of the actual location of
  #       temporary files

  my $self = shift;

  return if exists $self->{tmpdir};			# been here before

  my @lt = localtime();
  $self->{tmpuri} = sprintf("/tmp/%4d-%02d-%02d", $lt[5]+1900, $lt[4]+1, $lt[3]);
  $self->{tmproot} = defined $ENV{DOCUMENT_ROOT} ? $ENV{DOCUMENT_ROOT} : '';
  $self->{tmpdir} = "$self->{tmproot}/$self->{tmpuri}";

  if ( not -d $self->{tmpdir} ) {
	mkdir($self->{tmpdir})
	  || $self->die("mkdir($self->{tmpdir}: $!\n");
  }

  return $self->{tmpdir};
}


sub _cleanup_temp ($) {
  # This is intended to provide self-cleaning for Unison web page temp files
  my $self = shift;
  return unless defined $ENV{DOCUMENT_ROOT};
  my $root = "$ENV{DOCUMENT_ROOT}/tmp";
  my @lt = localtime();
  my $ts = sprintf("%4d-%02d-%02d", $lt[5]+1900, $lt[4]+1, $lt[3]);
  my @old = grep {m/^\d{4}-\d{2}-\d{2}$/ and $_ lt $ts} map {s%$root/%%;$_} <$root/200*>;
  my @tbd = map {"$root/$_"} @old;
  foreach my $dir (@tbd) {
	print(STDERR "temp file cleanup: removing $dir/\n");
	if (system("/bin/rm -fr $dir")) {
	  print(STDERR "FAILED: $dir: $!\n");
	}
  }
}





######################################################################
## page_variables()

=pod

=item B<< $p->page_variables( C<> ) >>

FOR DEBUGGING: render a list pf page variables

=cut

sub page_variables {
  my $self = shift;
  my $v = $self->Vars();
  return map {"<br><code>$_: $v->{$_}</code>\n"} (sort keys %$v);
}



=pod

=head1 INTERNAL ROUTINES (NON-METHODS)

These methods typically begin with two underscores (e.g., __internal_routine).

=over

=cut



## ## XXX: in use?
## commented out 2005-03-19 to see what breaks (rkh)
## sub where {
##   my $self = shift;
##   ($self->{Nav},$self->{SubNav}) = @_;
##   return $self;
## }



1;
