package Unison::WWW::Page;
use CGI qw( :standard *table -debug -nosticky );
our @ISA = qw(CGI);

use CGI::Carp qw(fatalsToBrowser);
use Unison::Exceptions;
use Unison;


sub new {
  my $class = shift;
  my $self = $class->SUPER::new( @_ );
  my $username = 'PUBLIC';
  my $v = $self->Vars();
  my $host;

  # establish session authentication, preferably via kerberos
  if (exists $v->{username}) {
	$username = $v->{username};
  } elsif (exists $ENV{REMOTE_USER}
		   and -f "/tmp/krb5cc_$ENV{REMOTE_USER}") {
	$username = $ENV{REMOTE_USER};
	$ENV{KRB5CCNAME}="FILE:/tmp/krb5cc_$username";
	$host = 'svc';							# must be svc for krb5 auth
  }

  try {
	$self->{unison} = new Unison( username => $username,
								  password => undef,
								  host => $host,
								  dbname => $v->{dbname} || 'csb' );
  }
  catch Unison::Exception with {
	my $msg = escapeHTML($_[0]);
	__PACKAGE__->die('Unison Connection Failed', 
					 '<pre>'.$msg.'</pre>',
					'<p>',
					 '<hr>Kerberos and user information:',
					 (map { "<br><code>$_: $ENV{$_}</code>\n" }
					  qw(REMOTE_USER KRB5CCNAME)),
					);
  };


  # Most pages should refer to sequences by pseq_id. If pseq_id isn't defined,
  # then we attempt to infer it from seq, md5, or alias (in that order).
  if (not exists $v->{pseq_id}) {
	my @ids;

	if (exists $v->{seq}) {
	  (@ids) = $self->{unison}->pseq_id_by_sequence( $v->{seq} );
	  if ($#ids == -1) {
		$self->die('sequence not found',
				   'The sequence you provided wasn\'t found in Unison.');
	  }
	} elsif (exists $v->{md5}) {
	  (@ids) = $self->{unison}->pseq_id_by_md5( $v->{md5} );
	  if ($#ids == -1) {
		$self->die('md5 checksum not found',
				   'The md5 checksum you provided wasn\'t found in Unison.');
	  } elsif ($#ids > 0) {
		# md5 collision! (hasn't happened yet and I don't expect it), but just in case...
		$self->die('md5 collision!',
				   'The md5 checksum you provided corresponds to more than one sequence.');
	  }
	} elsif (exists $v->{alias}) {
	  (@ids) = $self->{unison}->get_pseq_id_from_alias( $v->{alias} );
	  if ($#ids == -1) {
		$self->die('alias not found',
				   'The alias you provided wasn\'t found in Unison (case insensitive).');
	  } elsif ($#ids > 0) {
		# multiple aliases
		$self->die('alias collision',
				   'The alias you provided corresponds to more than one sequence.');
	  }
	}

	$v->{pseq_id} = $ids[0];
  }

  undef $v->{md5};
  undef $v->{seq};

  $self->start_html;
  return $self;
  }



sub header {
  my $p = shift;
  return '' if $p->{already_did_header}++;
  return $p->SUPER::header();
}

sub start_html {
  my $self = shift;
  return $self->SUPER::start_html( @_,
								   -head => [
											 Link({-rel => 'shortcut icon',
												   -href => '../av/favicon.png'})
										    ],
								   -style => { -src => ['../unison.css', '../styles/ToolTips.css'] },
								   -onload => 'javascript:{ initToolTips(); }',
								   -script => [ {-languange => 'JAVASCRIPT', -src => '../js/ToolTips.js'},
												{-languange => 'JAVASCRIPT', -src => '../js/DOM_Fixes.js'} ]
								 );
  }

sub render
  {
  my $p = shift;
  my $title = shift;
  return ($p->header(),

		  $p->start_html(-title=>"Unison: $title"), "\n\n\n",

		  '<table class="page">', "\n",

		  "\n<!-- ========== begin banner bar ========== -->\n",
		  '<tr>', "\n",
		  '  <td class="logo" width="10%">',
			 '<a title="Unison home page" href=".."><img height="25px" class="logo" src="../av/unison.png"></a>',
		     '</td>',"\n",
		  '  <td class="navbar" padding=0>', $p->navbar(), '</td>', "\n",
		  '</tr>', "\n",
		  "<!-- ========== end banner bar ========== -->\n",

		  "\n<!-- ========== begin page content ========== -->\n",
		  '<tr>', "\n",
		  '  <td class="cnav">',
		  
		     (map {"<b>$_:</b><br>"
					 . (defined $p->{unison}->{$_} ? $p->{unison}->{$_} 
						: 'unknown')
					 . '<p>'
				   } qw(username host dbname)),
             '</td>', "\n",
		  '  <td class="body">', 
		  "  <b>$title</b><br>", "\n", 
		  '  ', @_, "\n",
		  '  </td>', "\n",
		  "\n<!-- ========== end page content ========== -->\n",

		  "\n<!-- ========== begin footer ========== -->\n",
		  '<tr>', "\n",
		  '  <td class="logo"><a href="http://www.postgresql.org/"><img class="logo" src="../av/poweredby_postgresql.png"></a></td>', "\n",
		  '  <td class="contact">Please contact <a href="http://gwiz/local-bin/empshow.cgi?empkey=26599">Reece Hart</a> with suggestions or problems</td>', "\n",
		  '</tr>', "\n",
		  "\n<!-- ========== end footer ========== -->\n",

		  '</table>', "\n",

		  "\n", $p->end_html(),"\n"
		 );
  }


sub group {
  my $self = shift;
  my $name = shift;
  return("<table class=\"group\">\n" .
		 "<tr><th class=\"grouptag\">$name</th><th></th></tr>\n" .
		 "<tr><td colspan=\"2\">\n".join('',@_)."\n</td></tr>\n" .
		 "</table>\n");
}

sub Vars {
  my $p = shift;
  if (not exists $p->{Vars}) {
	$p->{Vars} = $p->SUPER::Vars();
  }
  return $p->{Vars};
}

sub navbar {
  my $p = shift;
  my $v = $p->Vars();
  my @navs =
	( [ # analyze MENU
	   ['Analyze', 'display precomputed analyses for a given sequence'],
	   ['Summary', 'summary of sequence information', 'pseq_summary.pl', "pseq_id=$v->{pseq_id}" ],
	   ['Aliases', 'all aliases of this sequence', 'pseq_paliases.pl', "pseq_id=$v->{pseq_id}"],
	   ['Patents', 'Patents on this sequence', 'pseq_patents.pl', "pseq_id=$v->{pseq_id}"],
	   ['Features', 'Sequences features', 'pseq_features.pl', "pseq_id=$v->{pseq_id}"],
	   ['BLAST', 'BLAST-related sequences', 'pseq_blast.pl', "pseq_id=$v->{pseq_id}"],
	   ['Prospect2', 'Prospect2 threadings', 'pseq_paprospect2.pl', "pseq_id=$v->{pseq_id};run_id=1"],
	   ['HMM', 'Hidden Markov Model alignments', 'pseq_pahmm.pl', "pseq_id=$v->{pseq_id}"],
	   ['PSSM', 'PSSM alignments', 'pseq_papssm.pl', "pseq_id=$v->{pseq_id}"],
	   ['Loci', 'Genomic localization', 'pseq_loci.pl', "pseq_id=$v->{pseq_id}"],
	  ],

	  [ # search menu
	   ['Search', 'search for sequences which match criteria' ],
	   ['By Sequence', 'search for sequences by subsequnce expression', 'search_by_sequence.pl'],
	   ['By Alias', 'search for sequences by alias/name/accession', 'search_by_alias.pl'],
	   ['By Properties', 'mine for sequences based on properties', 'search_by_properties.pl'],
	  ],

	  #[ # browse menu
	  # ['Browse', 'browse sets of sequences'],
	  # ['Sets', undef, 'browse_sets.pl'],
	  # ['Origins', undef, 'browse_origins.pl']
	  #],

	  #[ # run menu
	  # ['Run', 'run analyses on sequences for which precomputed results aren\'t available'],
	  # ['BLAST', undef, 'run_blast.pl'],
	  # ['Pfam', undef, 'run_pfam.pl']
	  #],

	  #[ # special menu
	  # ['Special', 'special projects'],
	  # ['UNQ', 'UNQ browsing']
	  #],

	  #[ # admin menu
	  # ['Admin', 'Unison administration'],
	  # ['Aliases', 'update aliases', 'pseq_paliases.pl', 'upd=1']
	  #],

	  # empty list forces right-justification of subsequent menu
	  [ [ '' ]  ],

	  [
	   ['Info', 'about Unison'],
	   ['About', 'about unison', 'about_unison.pl'],
	   ['Contents', 'show unison meta information', 'about_contents.pl'],
	   ['Credits', 'thanks, ma!', 'about_credits.pl'],
	   ['Home', 'go to Unison\'s low budget home page', '..'],
	   ['Env', 'Environment info', 'about_env.pl'],
	  ],
	);

  my ($navi,$subnavi) = $p->find_nav_ids(@navs);
  if (not defined $navi) {
	# oops... not in @navs
	push( @navs, [ $p->{Nav} ] );
	$navi = $#navs;
  }
  if (not defined $subnavi) {
	# oops... not in @{$navs[$navi]}
	push( @{$navs[$navi]}, [ $p->{SubNav}, undef ] );
	$subnavi = $#{$navs[$navi]};
  }
  my $rv;
  $rv .= make_navbar($navi, map {[ @{$_->[0]}, @{$_->[1]}[2,3]]} @navs);
  my @sn = @{$navs[$navi]}; shift @sn;
  $rv .= make_navbar($subnavi, @sn);
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
	my $tooltip = defined $tooltip ? ' tooltip="'.$tooltip.'"' : '';
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
  shift;
  return( "\n", '<p><div class="sql"><b>SQL query:</b> ',
		  join(' ',@_), '</div>', "\n" );
}

sub tip {
  shift;
  return( "\n",'<p><div class="tip"><b>Tip:</b> ', 
		  join(' ',@_), '</div>', "\n" );
}

sub warn {
  shift;
  return( "\n",'<p><div class="warning"><b>Warning:</b> ', 
		  join(' ',@_), '</div>', "\n" );
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





# build a url from the CGI query object
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

