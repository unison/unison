package Unison::WWW::Page;
use CGI qw( :standard *table -newstyle_urls -debug );
our @ISA = qw(CGI);

use Unison::Exceptions;
use Unison;


sub new {
  my $class = shift;
  my $self = $class->SUPER::new( @_ );
  my $username = $ENV{REMOTE_USER};

  # establish session authentication, preferably via kerberos
  if (defined $username and -f "/tmp/krb5cc_$username")
	{ $ENV{KRB5CCNAME}="FILE:/tmp/krb5cc_$username"; }
  else
	{ $username = 'PUBLIC'; }
  $username = 'PUBLIC';
  try { 
	$self->{unison} = new Unison( username=>$username, password=>undef ); 
  }
  catch Unison::Exception::ConnectionFailed with {
	die($self->header(),
		$self->start_html('Unison Connection Failed'),
		"<h1>Unison Connection Failed</h1>\n",
		$_[0],
		$self->end_html());
  };
#  print(STDERR "## unison = ", $self->{unison}, "\n");
  $self->start_html;
  return $self;
  }



sub header
  {
  my $p = shift;
  return '' if $p->{already_did_header}++;
  return $p->SUPER::header();
  }

sub start_html
  {
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

		  $p->start_html(-title=>"Unison:$title"), "\n\n\n",

		  '<table class="page">', "\n",

		  "\n<!-- ========== begin banner bar ========== -->\n",
		  '<tr>', "\n",
		  '  <td title="Unison home page" class="logo" width="10%"><a href=".."><img class="logo" src="../av/unison.png"></a></td>', "\n",
		  '  <td padding=0>', $p->navbar(), '</td>', "\n",
		  '</tr>', "\n",
		  "<!-- ========== end banner bar ========== -->\n",

		  "\n<!-- ========== begin page content ========== -->\n",
		  '<tr>', "\n",
		  '  <td class="cnav"><span tooltip=\'hi there\'>[future<br>expansion]</span></td>', "\n",
		  '  <td>', 
		  "  <b>$title</b><br>", "\n", 
		  '  ', @_, "\n",
		  '  </td>', "\n",
		  "\n<!-- ========== end page content ========== -->\n",

		  "\n<!-- ========== begin footer ========== -->\n",
		  '<tr>', "\n",
		  '  <td class="logo"><a href="http://www.postgresql.org/"><img class="logo" src="../av/poweredby_postgresql.png"></a></td>', "\n",
		  '  <td valign="top">contact:<a href="http://gwiz/local-bin/empshow.cgi?empkey=26599">Reece Hart</a></td>', "\n",
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

sub ensure_required_params
  {
  my $p = shift;
  foreach my $v (@_) {
	(defined $p->param($v))
	  || $p->die("The $v parameter wasn't defined.");
  }
  return;									# all needed params defined
}

sub die
  {
  my $p = shift;
  print $p->render("error: $_[0]",'<span class="error">',join('<br>',@_),'</span>');
  exit(0);
  }

sub debug {
  my $p = shift;
  print $p->render("debug: $_[0]",'<span class="debug">',join('<br>',@_),'</span>');
}



sub navbar {
  my $p = shift;
  my $v = $p->Vars();
  my @navs =
	( [ ['Analyze', 'display precomputed analyses for a given sequence'],
		['Summary', 'summary of sequence information', 'pseq_summary.pl', "pseq_id=$v->{pseq_id}" ],
		['Aliases', 'all aliases of this sequence', 'pseq_paliases.pl', "pseq_id=$v->{pseq_id}"],
		['Patents', 'Patents on this sequences', 'pseq_patents.pl', "pseq_id=$v->{pseq_id}"],
		['Features', 'Sequences features', 'pseq_features.pl', "pseq_id=$v->{pseq_id}"],
		['BLAST', 'BLAST-related sequences', 'pseq_blast.pl', "pseq_id=$v->{pseq_id}"],
		['Prospect2', 'Prospect2 threadings', 'pseq_paprospect2.pl', "pseq_id=$v->{pseq_id}"],
		['HMM', 'Hidden Markov Model alignments', 'pseq_pahmm.pl', "pseq_id=$v->{pseq_id}"],
		['PSSM', 'PSSM alignments', 'pseq_papssm.pl', "pseq_id=$v->{pseq_id}"],
		['Loci', 'Genomic localization', 'pseq_loci.pl', "pseq_id=$v->{pseq_id}"],
	  ],

	  [ ['Mine', 'mine for sequences which match criteria' ],
		['By Sequence', undef, 'mine_sequence.pl'],
		['By Alias', undef, 'mine_alias.pl'],
		['By Feature', undef, 'mine_feature.pl'],
	  ],

	  [ ['Browse', 'browse sets of sequences'],
		['Sets', undef, 'browse_sets.pl'],
		['Origins', undef, 'browse_origins.pl']
	  ],

	  [ ['Run', 'run analyses on sequences for which precomputed results aren\'t available'],
		['BLAST', undef, 'run_blast.pl'],
		['Pfam', undef, 'run_pfam.pl']
	  ],

	  [ ['Special', 'special projects'],
		['UNQ', 'UNQ browsing']
	  ],

#	  [ ['Admin', 'Unison administration'],
#		['Aliases', 'update aliases', 'pseq_paliases.pl', 'upd=1']
#	  ],

	  # force right-justified
	  [ [ '' ]  ],

	  [ ['Info', 'about Unison'],
		['About', 'about unison', 'about_unison.pl'],
		['Contents', 'show unison meta information', 'about_contents.pl'],
		['Credits', 'thanks, ma!', 'about_credits.pl'],
		['Home', 'go to Unison\'s low budget home page', '..'],
		['Perl', 'perl info', 'about_perl.pl'],
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
  # @tu = array ref of [title,descr,url,params]
  my ($sel,@tu) = @_;
  my $spacer = '<td width="%80"></td>';
  my @nav = ();
  for(my $i=0; $i<=$#tu; $i++) {
	my ($text,$title,$url,$params) = @{$tu[$i]};
	if ($text eq '') {
	  push(@nav, $spacer);
	  $spacer = '';
	  next;
	}
	my $cl = 'unselected';
	my $tooltip = defined $title ? ' tooltip="'.$title.'"' : '';
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
  return( '<p><div class="sql"><b>SQL query:</b> ' . $_[1] . '</span>' );
  # return '<br><span class="sql">', '<b>SQL query:</b>', $_[0], '</span>'
}
1;
