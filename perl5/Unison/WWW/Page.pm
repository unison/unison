package Unison::WWW::Page;
use warnings;

use base Exporter;
use CGI qw( -debug -nosticky -newstyle_urls);
push(@ISA, 'CGI');
BEGIN { (-t 0) || eval "use CGI::Carp qw(fatalsToBrowser)" }

use Unison::Exceptions;
use Unison;


#WARNING: strict must be last, unsure why
use strict;



sub page_connect ($);
sub infer_pseq_id ($);



our $infer_pseq_id = 0;


sub import {
  my $self = shift;
  for (@_) {
	$infer_pseq_id=1 if ($_ eq 'infer_pseq_id');
  }
}


sub new {
  my $class = shift;
  my $self = $class->SUPER::new( @_ );
  $self->{starttime} = time;
  my $v = $self->Vars();
  $v->{debug} = 0 unless defined $v->{debug};

  try {
	page_connect($self);
  }	catch Unison::Exception with {
	my $msg = CGI::escapeHTML($_[0]);
	__PACKAGE__->die('Unison Connection Failed', 
					 '<pre>'.$msg.'</pre>',
					 '<p>',
					 '<hr>Kerberos and user information:',
					 (map { "<br><code>$_: $ENV{$_}</code>\n" }
					  qw(REMOTE_USER KRB5CCNAME)),
					);
  };


  if (not exists $v->{pseq_id} and $infer_pseq_id) {
	my @st = grep {exists $v->{$_}} qw(q pseq_id seq md5 alias);
	if (@st > 1) {
	  $self->die("please don't provide more than one search term",
				 sprintf('You provided criteria for %d terms (%s)',
						 $#st+1, join(',',@st) ));
	}
	$v->{pseq_id} = infer_pseq_id($self);
	if (not defined $v->{pseq_id}) {
	  $self->die("couldn't infer pseq_id from arguments");
	}

	# hereafter, we don't want these polluting our variables
	delete $v->{'q'};
	delete $v->{alias};
	delete $v->{md5};
	delete $v->{seq};
  }

  $self->{userprefs} = $self->{unison}->get_userprefs();
  $self->{readonly} = 1;
  $self->{readonly} = 0 if ($self->{unison}->{dbname} eq 'csb-dev' 
							and $self->{unison}->{username} =~ m/^(rkh|cavs)$/
							and exists $v->{update} );

  # if we've made it this far, we'll eventually get a page out
  $self->start_html;

  return $self;
  }


sub page_connect ($) {
  my $self = shift;
  my $v = $self->Vars();

  # choose database based on port unless explicitly set
  # SERVER_PORT is always set, EXCEPT when debugging from the command line
  if (not exists $v->{dbname}) {
	my ($port) = $ENV{SERVER_PORT} || 80;
	$v->{dbname} = ($port == 8080) ? 'csb-dev'
	  			 : ($port == 8040) ? 'csb-stage'
	             :                   'csb';
  }

  # establish session authentication, preferably via kerberos
  #$v->{username} = 'PUBLIC' unless defined $v->{username};
  if (exists $ENV{REMOTE_USER} and -f "/tmp/krb5cc_$ENV{REMOTE_USER}") {
	$v->{username} = $ENV{REMOTE_USER};
	$ENV{KRB5CCNAME}="FILE:/tmp/krb5cc_$v->{username}";
	  $v->{host} = 'csb';						# must be this for krb5 auth
  }

  # NOTE: password=>undef works for PUBLIC and krb auth
  $self->{unison} = new Unison( username => $v->{username},
								password => undef,
								host => $v->{host},
								dbname => $v->{dbname} );

  return $self->{unison};
}



sub infer_pseq_id ($) {
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

	if ($q =~ m/Unison:(\d+)/)		{ return $1; };

	if (length($q)==32 and $q!~m/[^0-9a-f]/i) {
	  $v->{md5} = $q;
	} else {
	  $v->{alias} = $q;
	}
  }


  if (exists $v->{seq}) {
	my (@ids) = $self->{unison}->pseq_id_by_sequence( $v->{seq} );
	if ($#ids == -1) {
	  $self->die('sequence not found',
				 'The sequence you provided wasn\'t found in Unison.');
	}
	# REMINDER: can't be more than 1
	return $ids[0];
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
	  # this should be moved to a general search CGI
	  print CGI::redirect("search_by_alias.pl?alias=$v->{alias}");
	  #exit(0);
	  #$self->die('alias collision',
	  #		   'The alias you provided corresponds to more than one sequence.');
	}
	return $ids[0];
  }

  return undef;
}



sub header {
  my $p = shift;
  return '' if ref $p and $p->{already_did_header}++;
  return $p->SUPER::header();
}

sub start_html {
  my $self = shift;
  return $self->SUPER::start_html( @_,
								   -head => [
											 $self->Link({-rel => 'shortcut icon',
														  -href => '../av/favicon.png'})
										    ],
								   -style => { -src => ['../styles/unison.css', '../styles/ToolTips.css'] },
								   -onload => 'javascript:{ initToolTips(); }',
								   -script => [ {-languange => 'JAVASCRIPT', -src => '../js/ToolTips.js'},
												{-languange => 'JAVASCRIPT', -src => '../js/DOM_Fixes.js'} ]
								 );
  }

sub render {
  my $p = shift;
  my $title = shift;

  my $cnav = '';
  my $elapsed = '';

  if (ref $p and exists $p->{unison} and $p->{unison}->is_open()) {
	$cnav = join('<p>',
				 map( {"<b>$_->[0]:</b><br>&nbsp;&nbsp;$_->[1]"}
					  # key-value pairs:
					  (map {[$_,(defined $p->{unison}->{$_} ? $p->{unison}->{$_} : 'unknown')]}
					   qw(username host dbname)),

					  ['db<br>release',
					   $p->{unison}->selectrow_array
					   ('select value::date from meta where key=\'release timestamp\'')],

					  ['API<br>release', $Unison::RELEASE],
					  ['WWW<br>release', $Unison::WWW::RELEASE]
					)
				);
	$cnav .= '<p><center><span style="background-color: red"><b><i>&nbsp;&nbsp;writable&nbsp;&nbsp;</i></b></span></center>' if (not $p->{readonly});
	$elapsed = 'page generated in ' . (time - $p->{starttime}) . ' seconds';
  }

  return ($p->header(),

		  $p->start_html(-title=>"Unison: $title"), "\n\n\n",

		  '<table class="page">', "\n",

		  "\n<!-- ========== begin banner bar ========== -->\n",
		  '<tr>', "\n",
		  '  <td class="logo" width="10%">',
		  '<a title="Unison home page" href=".."><img class="logo" src="../av/unison.gif"></a>',
		  '</td>',"\n",
		  '  <td class="navbar" padding=0>', $p->navbar(), '</td>', "\n",
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
		  '  <td class="logo"><a href="http://www.postgresql.org/"><img class="logo" src="../av/poweredby_postgresql.gif"></a></td>', "\n",
		  '  <td class="contact">Please contact <a href="http://gwiz/local-bin/empshow.cgi?empkey=26599">Reece Hart</a> with suggestions or problems<br>', $elapsed, '</td>', "\n",
		  '</tr>', "\n",
		  "\n<!-- ========== end footer ========== -->\n",

		  '</table>', "\n",

		  "\n", $p->end_html(),"\n"
		 );
}


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

sub Vars {
  my $p = shift;
  return unless ref $p;
  if (not exists $p->{Vars}) {
	$p->{Vars} = $p->SUPER::Vars();
  }
  return $p->{Vars};
}

sub navbar {
  my $p = shift;
  my $v = $p->Vars() || {};
  my $pseq_id = exists $v->{pseq_id} ? "pseq_id=$v->{pseq_id}" : '';
  my @navs =
	## format: @navs = ( menu, menu, ... );
	## where each menu is
	## [ [ name, tooltip ],
	##   [ sub1, tooltip1, script1, args1 ],
	##   [ sub2, tooltip2, script2, args2 ],
	##   ...
	## ]
	( [ # analyze MENU
	   ['Analyze', 		'display precomputed analyses for a given sequence'],
	   ['Summary', 		'summary of sequence information', 	'pseq_summary.pl', 	$pseq_id ],
	   ['Aliases', 		'all aliases of this sequence', 	'pseq_paliases.pl', $pseq_id ],
	   ['Patents', 		'patents on this sequence', 		'pseq_patents.pl', 	$pseq_id ],
	   ['Features',		'sequences features', 				'pseq_features.pl', $pseq_id ],
	   ['BLAST', 		'BLAST-related sequences', 			'pseq_blast.pl', 	$pseq_id ],
	   ['Prospect2', 	'Prospect2 threadings', 			'pseq_paprospect2.pl', "$pseq_id;params_id=1"],
	   ['HMM', 			'Hidden Markov Model alignments', 	'pseq_pahmm.pl', 	$pseq_id ],
	   ['PSSM',			'PSSM alignments', 					'pseq_papssm.pl', 	$pseq_id ],
	   ['Loci',			'genomic localization', 			'pseq_loci.pl', 	$pseq_id ],
	   ['Notes',		'user notes on this sequnece',		'pseq_notes.pl', 	$pseq_id ],
	   ['History',		'run history',						'pseq_history.pl', 	$pseq_id ],
	  ],

	  [ # search menu
	   ['Search', 		'search for sequences which match criteria' ],
	   ['By Sequence',	'search for sequences by subsequnce expression', 'search_by_sequence.pl'],
	   ['By Alias',		'search for sequences by alias/name/accession', 'search_by_alias.pl'],
	   ['By Properties','mine for sequences based on properties', 'search_by_properties.pl'],
	   ['Compare Sets',	'compare a set of sequences to a set of models ', 'search_sets.pl'],
	  ],

	  [ # browse menu
	   ['Browse', 'browse curated sets of sequences (unimplemented)'],
	   ['Sets', 'browse <i>precomputed</i> sets of proteins', 'browse_sets.pl'],
	   ['Views', 'browse dynamic queries of protein sequences', 'browse_views.pl'],
	  # ['SCOP', undef, 'browse_scop.pl'],
	  # ['Origins', undef, 'browse_origins.pl']
	  ],

	  # empty list forces right-justification of subsequent menu
	  [ [ '' ]  ],

	  [
	   ['Help', 		'Help using Unison'],
	   ['Tips',			'Tips', 						'about_prefs.pl'],
	  ],

	  [
	   ['Info', 		'about Unison'],
	   ['About', 		'about unison', 				'about_unison.pl'],
	   ['Contents', 	'show unison meta information', 'about_contents.pl'],
	   ['Credits', 		'thanks, ma!',					'about_credits.pl'],
	   ['Home', 		'go to Unison\'s low budget home page', '..'],
	   ['Env', 			'Environment info', 			'about_env.pl'],
	   ['Prefs',		'User Prefs', 					'about_prefs.pl'],
	  ]


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

  my ($navi,$subnavi) = $p->find_nav_ids(@navs);
  # if (not defined $navi) {
  # 	# oops... not in @navs
  # 	push( @navs, [ $p->{Nav} ] );
  # 	$navi = $#navs;
  # }
  # if (not defined $subnavi) {
  # 	# oops... not in @{$navs[$navi]}
  # 	push( @{$navs[$navi]}, [ $p->{SubNav}, undef ] );
  # 	$subnavi = $#{$navs[$navi]};
  # }

  my $rv = '';
  $rv .= make_navbar($navi, map {[ @{$_->[0]}, @{$_->[1]}[2,3]]} @navs);
  if (defined $navi) {
	my @sn = @{$navs[$navi]}; shift @sn;
	$rv .= make_navbar($subnavi, @sn);
  }
  return $rv;
}


sub find_nav_ids {
  my $p = shift;
  my @navs = @_;
  my $script = $p->url(-relative => 1);
  for(my $i=0; $i<=$#navs; $i++) {
	my @snavs = @{$navs[$i]};
	shift @snavs;
	for(my $j=0; $j<=$#snavs; $j++) {
	  return($i,$j) if (defined $snavs[$j]->[2] and $snavs[$j]->[2] eq $script);
	}}
  return;
  }


sub best_annotation {
  my $p = shift;
  my $pseq_id = shift;

  return( $p->tooltip( 'current "best" annotation', 'Best annotations are
					   a guess about the most informative and reliable
					   annotation for this sequence from all source
					   databases. Click the Aliases tab to see all
					   annotations' ),
		  ': ',
		  $p->{unison}->best_annotation($pseq_id,1) );
}

sub make_navbar {
  # $sel is which is selected
  # @tu = array ref of [text,tooltip,url,params]
  my ($sel,@tu) = @_;
  my $spacer = '<td width="%80"></td>';
  my @nav = ();
  for(my $i=0; $i<=$#tu; $i++) {
	my ($text,$tooltip,$url,$params) = @{$tu[$i]};
	$text =~ s/ /&nbsp;/g;
	if ($text eq '') {
	  push(@nav, $spacer);
	  $spacer = '';
	  next;
	}
	my $cl = 'unselected';
	$tooltip = defined $tooltip ? ' tooltip="'.$tooltip.'"' : '';
	$url .= "?$params" if defined $params;
	if (defined $sel and $sel == $i) {
	  $cl = 'selected';
	  $url = undef;
	}
	push(@nav, "<td class=\"$cl\">"
		 . (defined $url ? "<a href=\"$url\"$tooltip>$text</a>" : "<span$tooltip>$text</span>")
		 . "</td>" );
  }
  return( '<table class="nav" width="100%">'
		  . join('<td class="spc" width=1></td>', @nav)
		  . $spacer
		  . '</table>' );
}

sub where {
  my $self = shift;
  ($self->{Nav},$self->{SubNav}) = @_;
  return $self;
}

sub sql {
  my $self = shift;
  return '' unless $self->{userprefs}->{'show_sql'};
  return( "\n", '<p><div class="sql"><b>SQL query:</b> ',
		  @_,
		  '</div>', "\n" );
}

sub tip {
  my $self = shift;
  return '' unless $self->{userprefs}->{'show_tips'};
  return( "\n",'<p><div class="tip"><b>Tip:</b> ', @_, '</div>', "\n");
}

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

sub warn {
  my $self = shift;
  return( "\n",'<p><div class="warning"><b>Warning:</b> ', 
		  @_, '</div>', "\n" );
}

sub ensure_required_params {
  my $p = shift;
  my @ud = grep { not defined $p->param($_) or $p->param($_) eq '' } @_;
  return 0 unless @ud;
  $p->die('Missing parameters',
		  '<br>The follow parameters were missing:',
		  '<br>&nbsp;&nbsp;&nbsp; <code>' . join(', ', @ud) . '</code>' );
  # doesn't return
}

sub die {
  my $p = shift;
  my $t = shift;
  print $p->render( "Error: $t",
					'<p><div class="warning">',
					'<b>Error:</b> ', $t, '<br>',
					join(' ',@_), 
					'</div>', "\n" );
  exit(0);
}

sub debug {
  my $p = shift;
  print $p->render("debug: $_[0]",'<span class="debug">',join('<br>',@_),'</span>');
}





# build a url from the CGI query object with values from a specified variable list
# use:
# 
sub make_url {
  my $p = shift;
  my $vars = $p->Vars();
  my $addlvars = ref $_[0] ? shift : {};
  my %vars = (%$vars, %$addlvars);

  my @keys;
  if (@_) {									# specified query vars only
	my %keys = map { $_=>1 } @_, keys %$addlvars;
	@keys = sort keys %keys;
  } else {									# or default is all vars
	@keys = sort keys %vars;
  }

  my $url = $p->url(-relative=>1);

  my $qargs = join( ';', map {"$_=$vars{$_}"} grep {defined $vars{$_}} @keys);
  $url .= '?' . $qargs if $qargs ne '';

  return $url;
}




1;

