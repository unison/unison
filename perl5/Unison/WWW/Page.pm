=head1 NAME

Unison::WWW::Page -- Unison web page framework

S<$Id: Page.pm,v 1.69 2005/11/21 05:58:24 rkh Exp $>

=head1 SYNOPSIS

 use Unison::WWW::Page;
 my $p = new Unison::WWW::Page;

=head1 DESCRIPTION

B<Unison::WWW::Page> provides a class for consistent rendering of Unison
web pages. It's simple and not powerful.

=cut


## BEGIN {
##   # if $log_fn below exists and is writable, then we'll open it for logging.
##   # NOTE: the file must be writable by the web server.
##   # Typically, do something like:
##   # $ touch /tmp/unison-rkh.log
##   # $ chmod a+w /tmp/unison-rkh.log
##   # to enable logging.
##   # THIS WILL SLOW THINGS DOWN... DON'T FORGET TO DELETE THE LOG!
##   if (exists $ENV{REMOTE_USER}) {
## 	my $log_fn = "/tmp/unison-$ENV{REMOTE_USER}.log";
## 	if (-f $log_fn and -w $log_fn) {
## 	  close(STDERR);
## 	  if (not open(STDERR, ">>$log_fn")) {
## 		# this error will end up on the web server error log
## 		print(STDERR __PACKAGE__ . ':' . __LINE__ . ": $log_fn: $!\n");
## 		exit(0);
## 	  }
## 	  $ENV{DEBUG} = 1;
## 	}
##   }
## }


package Unison::WWW::Page;
use Unison::WWW;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use warnings;

use base Exporter;
use CGI qw(-debug -nosticky -newstyle_urls);
use CGI::Carp qw(fatalsToBrowser);
push(@ISA, 'CGI');

use strict;

use Unison;
use Unison::Exceptions;
use Unison::WWW::userprefs;
use Unison::WWW::utilities qw( text_wrap );
use File::Temp;
use Text::Wrap;


sub _csb_connection_params ($);
sub _page_connect ($);
sub _infer_pseq_id ($);
sub _make_temp_dir ();
sub _cleanup_temp($$);
sub __filter_navs($$@);

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
	if (not defined $ENV{SERVER_NAME} or $ENV{SERVER_NAME} eq 'csb') {
	  _csb_connection_params($self) 
	}
	_page_connect($self);
  }	catch Unison::Exception with {
	$self->die_with_exception($_[0],
							  # plus some addition stuff to tack on...
							  'Relevant environment settings:',
							  join('', map( { "<br><code>$_: "
											  .(defined $ENV{$_} ? 
												$ENV{$_} : '<i>undef</i>')
											  ."</code>\n" }
											qw(REMOTE_USER KRB5CCNAME) ))
							 );
  };


  $self->{userprefs} = $self->{unison}->get_userprefs();
  $self->{readonly} = 1;
  $self->{js_tags} = [
					  {-language => 'JAVASCRIPT', 
					   -src => '../js/domTT/domLib.js'},
					  {-language => 'JAVASCRIPT',
					   -src => '../js/domTT/domTT.js'},
					  {-language => 'JAVASCRIPT',
					   -src => '../js/unison_domTT.js'},
					  {-language => 'JAVASCRIPT', 
					   -code => "var domTT_styleClass = 'domTTUnison';"}
					 ];

  # all pseq_id inference should be moved elsewhere...
  if (not exists $v->{pseq_id} and $infer_pseq_id) {
	my @st = grep {exists $v->{$_}} qw(q pseq_id seq md5 alias);
	if (@st > 1) {
	  $self->die("please don't provide more than one search parameter",
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
  my @undefd = grep { not defined $self->param($_)
						or $self->param($_) eq '' } @_;
  return 0 unless @undefd;
  $self->die('Missing parameters',
		  '<br>The follow parameters were missing:',
		  '<br>&nbsp;&nbsp;&nbsp; <code>' . join(', ', @undefd) . '</code>' );
  # doesn't return
}


######################################################################
## ensure_required_params()

=pod

=item B<< $p->is_valid_pseq_id( C<pseq_id> ) >>

Ensure that the pseq_id is valid and throw an exception if not.

=cut

sub is_valid_pseq_id {
  my $self = shift;
  my $q = shift;
  return 1 unless defined $q;
  return 1 if $self->{unison}->get_sequence_by_pseq_id($q);
  throw Unison::Exception("Unison:$q doesn't exist");
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
	if ($params[$i] eq '-script'
		and ref($params[$i+1]) eq 'HASH') {
	  push(@{$self->{js_tags}}, $params[$i+1]);
	}
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
	  -style => { -src => ['../styles/unison.css'] },
	  -target => '_top',
	  -onload => 'javascript:{ unison_activateTooltips(); }',
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

  my $conn_info = '';
  my $elapsed = '';

  if (ref $self and defined $self->{unison} and $self->{unison}->is_open()) {
	# conn_info isn't currently used... it takes up too much space to display
	# I think it would be better in a mouseover popup
	#$conn_info .= sprintf("release: Unison %s; API %s; www %s  %s\n",
	#					  ( $self->{unison}->selectrow_array
	#						('select value::date from meta where key=\'release timestamp\'') || 'N/A' ),
	#					  $Unison::RELEASE,
	#					  $Unison::WWW::RELEASE,
	#					  ( is_dev_instance() ? '<span style="background-color: red">DEVELOPMENT</span>' : '' )
	#					 );
	#$conn_info .= sprintf("<br>web connection: host %s\n",
	#					  $ENV{SERVER_NAME});
	#$conn_info .= sprintf("<br>db connection: %s @ %s/%s\n",
	#				  ['db host', 	$self->{unison}->{host} || 'local' ],
	#				  ['database',	$self->{unison}->{dbname}		   ],
	#				  ['username', 	$self->{unison}->{username}		   ],
	#					 );

	$elapsed = 'page generated in ' . (time - $self->{starttime}) . ' seconds';
  }

  return ($self->header(),

		  $self->start_html(-title=>"Unison: $title"), "\n\n\n",

		  '<table class="page">', "\n",
		  "\n<!-- ========== begin banner bar ========== -->\n",
		  '<tr>', "\n",
		  '  <td class="logo" width="10%">',
		  '<a href="../index.html"><img class="logo" src="../av/unison.gif"></a>',
		  '</td>',"\n",
		  '  <td class="navbar" padding=0>', $self->_navbar(), '</td>', "\n",
		  '</tr>', "\n",
		  "<!-- ========== end banner bar ========== -->\n",


		  "\n<!-- ========== begin body ========== -->\n",
		  '<tr><td colspan=2 class="body">', "\n",
		  '<span class="page_title">',$title,'</span>', "\n", 
		  '<br>', @_, "\n",
		  '</td></tr>', "\n",
		  "\n<!-- ========== end body ========== -->\n",


		  "\n<!-- ========== begin footer ========== -->\n",
		  '<tr>', "\n",
		  '  <td class="logo"><a href="http://www.postgresql.org/"><img class="logo" ',
		        ' src="../av/poweredby_postgresql.gif"></a></td>', "\n",
		  '  <td class="footer">',
		  '  Questions?  Email <a href="mailto:unison@unison-db.org?subject=Unison Question&body=Regarding ',
		     $self->url(), ' : ',
		     '">unison@unison-db.org</a>.',
		  '  &nbsp; &nbsp; ',
		  '  Bugs and requests? Use the <a href="http://sourceforge.net/tracker/?group_id=140591">Issue Tracker</a>.',
		  '     <br>',$elapsed, "\n",
		  (defined $self->{footer} ? (map {"<br>$_"} @{$self->{footer}}) : ''),
		  "  </td>\n",
		  "</tr>\n",
		  "\n<!-- ========== end footer ========== -->\n",

		  "</table>\n",

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
  #return '' unless $self->{userprefs}->{'show_sql'};
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

=item B<< tooltip( C<text>, C<tip> ) >> (without object reference)

Format C<tip> as a "tooltip" which will appear when the mouse is over
C<text>.

=cut

sub tooltip {
  shift if ref $_[0];						# method or fx
  my ($text,$tooltip,$class) = @_;
  return $text unless defined $tooltip;
  local $Text::Wrap::columns = 80;
  $tooltip =~ s/\s+/ /g;
  $tooltip = Text::Wrap::wrap('','',$tooltip);
  $tooltip =~ s/\n/<br>/g;
  $class = 'tooltip' unless defined $class;
  my $cltag = $class eq '' ? '' : "class=\"$class\"" ;
  return( "<span $cltag tooltip=\"$tooltip\">$text</span>" );
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
  print $self->render("Error: $t",
					  '<p><div class="warning">',
					  '<b>Error:</b> ', $t, '<br>',
					  join(' ',@_), 
					  '</div>', "\n" );
  exit(0);
}

sub die_with_exception {
  my $self = shift;
  my $ex = shift;
  $self->die(__FILE__.':'.__LINE__.": die_with_exception called without an exception\n",
			 '(instead it was called with a '.(ref($ex)||'non-reference').').') 
	unless (ref $ex and $ex->isa('Unison::Exception'));
  my $ex_text = ( defined $ex->{error} ? CGI::escapeHTML($ex->{error}) : '(no exception summary)' );
  $self->die($ex->error(),'<pre>'.$ex.'</pre>', (@_ ? ('<hr>', @_) : '') );
  # no return
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
  my $tooltip = <<EOT;
A best annotation is a guess about the most informative and reliable
annotation for this sequence from all source databases.
<br>Click the Aliases tab to see all annotations
EOT
  return( $self->tooltip( '"best" annotation', $tooltip ),
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
## is_prd_instance

=pod

=item B<< ::is_prd_instance() >>

Return true if this is a production version of Unison.

=cut
sub is_prd_instance {
  return 1 if (defined $ENV{SERVER_PORT} and $ENV{SERVER_PORT}==80);
  return 0;
}


######################################################################
## is_dev_instance

=pod

=item B<< ::is_dev_instance() >>

Return true if this is NOT on the production port (80) OR if the page is
being served by a user development directory

=cut
sub is_dev_instance {
  return not is_prd_instance();
}


######################################################################
## is_public

=pod

=item B<< ::is_public() >>

Return true if these pages are being served at a public Unison URL.  This
method is intended to facilitate hiding features which will fail because
they depend on data that are not released with Unison.

=cut
sub is_public {
  return 1 if defined $ENV{SERVER_ADDR} and $ENV{SERVER_ADDR} !~ m/^128\.137\./; # .gene.com domain
  return 0;
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

  $v->{host}	 = undef	unless defined $v->{host};
  $v->{dbname} 	 = 'unison'	unless defined $v->{dbname};
  $v->{username} = 'PUBLIC'	unless defined $v->{username};
  $v->{password} = undef	unless defined $v->{password};

  #printf(STDERR "# ci = (%s,%s,%s,%s,%s)\n",
  #		 (map {$v->{$_}||'undef'} qw(host dbname username password)),
  #		 $ENV{KRB5CCNAME} || 'wo/krb');

  # NOTE: password=>undef works for PUBLIC and krb auth
  # I got errors when it wasn't explicitly listed
  $self->{unison} = new Unison( host => $v->{host},
								dbname => $v->{dbname},
								username => $v->{username},
								password => $v->{password} );
  # Errors are caught by exceptions.


  # Set PG vars so that spawned apps connect to the same database
  # This will only work for kerberos authentication
  if ($v->{host}	) { $ENV{PGHOST}     = $v->{host}	  } else { delete $ENV{PGHOST}     };
  if ($v->{database}) { $ENV{PGDATABASE} = $v->{database} } else { delete $ENV{PGDATABASE} };
  if ($v->{username}) { $ENV{PGUSER}     = $v->{username} } else { delete $ENV{PGUSER}     };
  if ($v->{password}) { $ENV{PGPASSWORD} = $v->{password} } else { delete $ENV{PGPASSWORD} };

  return $self->{unison};
}


######################################################################
## _csb_connection_params
sub _csb_connection_params ($) {
  my $self = shift;
  my $v = $self->Vars();

  if (defined $ENV{SERVER_PORT}) {
	if    ($ENV{SERVER_PORT} ==   80)  { $v->{dbname} = 'csb'       }
	elsif ($ENV{SERVER_PORT} == 8040)  { $v->{dbname} = 'csb-stage' }
	elsif ($ENV{SERVER_PORT} == 8080)  { $v->{dbname} = 'csb-dev'   }
  }

  # If KRB5CCNAME is set, we're doing kerberos authentication.
  if (defined $ENV{KRB5CCNAME}) {
	$v->{username} = $ENV{REMOTE_USER} 		# from webserver...
	                 || `/usr/bin/id -un`;	# ... or debugging on command line
	$v->{username} =~ s/@.+//;				# strip domain from krb user name

	# pg_hba.conf requires tcp connection for kerberos
	# (This doesn't work with 'localhost', I think because we've got 2
	# names for csb.)
	$v->{host} = 'csb';
  }

  return;
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

  # if q is defined, quess what type it is and assign it to
  # an appropriate query term
  if ( exists $v->{'q'} ) {
	my $q = $v->{'q'};
	if ($q !~ m/\D/) {						# only numbers
	  $v->{pseq_id} = $q;
	} elsif (length($q)==32 and $q!~m/[^0-9a-f]/i) { # md5
	  $v->{md5} = $q;
	} elsif (length($q)>20 and $q!~m/[^A-Z]/) {
	  $v->{seq} = $q;
	} else {
	  $v->{alias} = $q;
	}
  }

  if (defined $v->{pseq_id}) {
	return $v->{pseq_id}
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
	  print CGI::redirect("search_alias.pl?alias=$v->{alias}");
	  exit(0);
	}
	return $ids[0];
  }

  # if we don't have a pseq_id by this point, we need to
  # throw up a generic search box
  print $self->render('Please specify a sequence',
					  '<p>Please specify a protein sequence by sequence alias/accession, Unison pseq_id, or md5 checksum.',
					  '<br><i>e.g.,</i> <code>TNFA_HUMAN, P01375, ENSP00000229681, NP_000585.2, IPI00001671.1, 60ada54e69e411bcf6b08e9dacff7a48</code>',

					  $self->start_form(-method => 'GET'),
					  'query: ',
					  $self->textfield(-name=>'q',
									   -size=>32,
									   -maxlength=>32),
					  $self->submit(-value=>'submit'),
					  '<p>',
					  $self->end_form(), "\n",
					  'You may wish to use the more advanced search abilities under the "Search" tab instead.'
					 );
  exit(0);

  # NO RETURN
}


######################################################################
## _navbar

sub _nav_dump {
  eval 'use Data::Dumper;  $Data::Dumper::Indent = 0;';
  my $n = shift;
  my $d = Dumper(\@_);
  $d =~ s/\],/],\n/g;
  print(STDERR "$n: ",$#_+1," items:\n",$d,"\n");
}

sub _navbar {
  my $self = shift;
  my $v = $self->Vars() || {};
  my $pseq_id = exists $v->{pseq_id} ? "pseq_id=$v->{pseq_id}" : '';
  my @navs =
	## format: @navs = ( menu, menu, ... );
	## where each menu is
	## [
	##   [ prd, pub, major_name, tooltip ],
	##   [ prd, pub, minor_name, tooltip, script, args ],
	##   [ prd, pub, minor_name, tooltip, script, args ],
	##   ...
	## ]
	## prd = production? 1=yes, 0=no (i.e., show ONLY in production)
	## pub = public? 1=yes, 0=no (i.e., show ONLY in public version)
	(
	 [	# Search menu
	  [1,1,'Search', 		'Text- and Feature-based mining',	'search_alias.pl'],
	  [1,1,'By Alias',		'search for sequences by alias/name/accession', 'search_alias.pl'],
	  [1,1,'By Properties',	'mine for sequences based on properties', 'search_properties.pl'],
	  [1,0,'Compare Sets',	'compare a set of sequences to a set of models ', 'search_sets.pl'],
	  [1,0,'Framework',    	'search for sequences matching a set of sequence regions', 'search_framework.pl'],
	 ],

	 [	# Browse menu
	  [1,1,'Browse', 		'browse curated queries and precomputed sequences sets', 'browse_views.pl'],
	  [1,1,'Views', 		'browse dynamic queries of protein sequences', 'browse_views.pl'],
	  [1,1,'Sets', 			'browse <i>precomputed</i> sets of proteins', 'browse_sets.pl'],
	 ],

	 [	# Analyze menu
	  [1,1,'Analyze', 		'display precomputed analyses for a single sequence', 'pseq_summary.pl' ],
	  [1,1,'Summary', 		'summary of sequence information', 	'pseq_summary.pl', 	$pseq_id ],
	  [1,1,'Aliases', 		'all aliases of this sequence', 	'pseq_paliases.pl', $pseq_id ],
	  [1,0,'Patents', 		'patents on this sequence', 		'pseq_patents.pl', 	$pseq_id ],
	  [1,1,'Features',		'sequences features', 				'pseq_features.pl', $pseq_id ],
	  [1,1,'Structure',		'structural features', 				'pseq_structure.pl', $pseq_id ],
	  [0,1,'BLAST', 		'BLAST-related sequences', 			'pseq_blast.pl', 	$pseq_id ],
	  [1,1,'Prospect',	 	'Prospect2 threadings', 			'pseq_paprospect.pl', $pseq_id],
	  [1,1,'HMM', 			'Hidden Markov Model alignments', 	'pseq_pahmm.pl', 	$pseq_id ],
	  [0,1,'PSSM',			'PSSM alignments', 					'pseq_papssm.pl', 	$pseq_id ],
	  [1,1,'Interactions',	'Protein-Protein Interactions', 	'pseq_intx.pl',		$pseq_id ],
	  [1,1,'Loci',			'genomic localization', 			'pseq_loci.pl', 	$pseq_id ],
	  [0,0,'Notes',			'user notes on this sequence',		'pseq_notes.pl', 	$pseq_id ],
	  [1,1,'History',		'run history',						'pseq_history.pl', 	$pseq_id ],
	 ],

	 [	# Assess menu
	  [0,0,'Assess', 		'compare sequence sets and analysis methods', 'compare_scores.pl'],
	  [0,0,'Scores', 		'compare scoring systems',			'compare_scores.pl'],
	  [0,0,'Methods', 		'compare threading methods',		'compare_methods.pl'],
	 ],

	 # empty list forces right-justification of subsequent menus
	 [ [ '' ]  ],

	 [	# About menu
	  [1,1,'About', 		'more information about Unison', 	'about_unison.pl'],
	  [1,1,'About Unison',	'Unison overview', 					'about_unison.pl'],
	  [1,1,'Statistics',	'Unison summary statistics',		'about_statistics.pl'],
	  [1,1,'Origins', 		'Unison data sources',			 	'about_origins.pl'],
	  [1,1,'Params', 		'Unison precomputed data types', 	'about_params.pl'],
	  [0,1,'Env', 			'environment info', 				'about_env.pl'],
	  [0,1,'Prefs',			'user prefs', 						'about_prefs.pl'],
	 ],

	  #[ # run menu
	  # [1,1,'Run', 'run analyses on sequences for which precomputed results aren\'t available'],
	  # [1,1,'BLAST', undef, 'run_blast.pl'],
	  # [1,1,'Pfam', undef, 'run_pfam.pl']
	  #],

	  #[ # special menu
	  # [1,1,'Special', 'special projects'],
	  # [1,1,'Preferences', 'user preferences']
	  # [1,1,'UNQ', 'UNQ browsing']
	  #],

	  #[ # admin menu
	  # [1,1,'Admin', 'Unison administration'],
	  # [1,1,'Aliases', 'update aliases', 'pseq_paliases.pl', 'upd=1']
	  #],

	);


  @navs = __filter_navs($self->is_prd_instance(),$self->is_public(),@navs);
  my ($navi,$subnavi) = $self->_find_nav_ids(@navs);
  my $rv = '';
  $rv = "\n  <table    class=\"nav\" width=\"100%\">"
	. "\n    <tr>"
	  . _make_navrow($navi, map {$_->[0]} @navs)
	  . '</tr>'
	. "\n" . '<tr>'  
	. ($navi==0      ? '' : sprintf('<td colspan=%d></td>',$navi))
	. '<td align="center"><img src="../av/v.gif"></td>'
	. ($navi==$#navs ? '' : sprintf('<td colspan=%d></td>',$#navs-$navi))
	. '</tr>'
	. "\n  </table>\n";

  my @nav = @{$navs[$navi]};
  shift @nav;				# menu header is first item; subnav items remain
  $rv .= "\n  <table class=\"subnav\" width=\"100%\">" 
	. '<tr>' . _make_navrow($subnavi, @nav) . '</tr>'
	. "</table>\n";

  return $rv;
}


sub __filter_navs($$@) {
  ## Purpose: remove development tabs from production environments, and remove
  ## proprietary tabs from public environments.

  my ($is_prd,$is_pub,@navs) = @_;
  foreach(my $i=$#navs; $i>=0; $i--) {
	if (    ($is_prd and not $navs[$i][0][0])
		 or ($is_pub and not $navs[$i][0][1]) ) {
	  splice(@navs,$i);						# entire major menu is tossed
	  next;
	}
	# else...
	#_nav_dump("$i.1",@navs);
	@{$navs[$i]} = grep {(    (not $is_prd or $_->[0])
						  and (not $is_pub or $_->[1]) )} @{$navs[$i]};
	#_nav_dump("$i.2",@navs);
	@{$navs[$i]} = map { $_->[0] eq '' ? [''] : [splice(@$_,2)] } @{$navs[$i]};
	#_nav_dump("$i.3",@navs);
  }
  #_nav_dump("is_prd=$is_prd; is_pub=$is_pub; returned=",@navs);
  return @navs;
}




sub _find_nav_ids {
  # identify indexes in  major and minor @nav entries for
  # the current page
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
	$url .= "?$params" if defined $params;
	my $cl = 'unselected';
	if (defined $sel and $sel == $i) {
	  $cl = 'selected';
	  $url = undef;
	}
	push(@nav, "<td class=\"$cl\">"
		 . tooltip( (defined $url ? "<a href=\"$url\">$text</a>" : $text), $tooltip, '' )
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
  my $date = sprintf("%4d-%02d-%02d", $lt[5]+1900, $lt[4]+1, $lt[3]);
  $self->{tmproot} = defined $ENV{DOCUMENT_ROOT} ? $ENV{DOCUMENT_ROOT} : '/';
  $self->{tmpuri} = "tmp/$date";
  $self->{tmpdir} = "$self->{tmproot}/$self->{tmpuri}";

  if ( not -d $self->{tmpdir} ) {
	mkdir($self->{tmpdir})
	  || $self->die("mkdir($self->{tmpdir}: $!\n");
	$self->_cleanup_temp($date);			# cleanup dirs before date
  }

  return $self->{tmpdir};
}


sub _cleanup_temp ($$) {
  # This is intended to provide self-cleaning for Unison web page temp files
  my $self = shift;
  my $date = shift;
  my $root = "$self->{tmproot}/tmp";
  my @old = grep {m%^$root/\d{4}-\d{2}-\d{2}$% and $_ lt "$root/$date"} 
	glob("$root/*");
  foreach my $dir (@old) {
	if (system("/bin/rm -fr $dir")) {
	  print(STDERR "FAILED: $dir: $!\n");
	}
	print(STDERR "temp dir cleanup: removed $dir/\n");
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

######################################################################
## iframe()

=pod

=item B<< $p->iframe( C<title>, C<body elems, ...> ) >>

Generates a Unison iframe with title given C<title> and with the
page-specific content provided by an array of C<body elems>.

=cut


sub iframe {
  my $self = shift;
  my $title = shift;
  my $src= shift;

  return <<EOHTML;
<style type="text/css">
div.iframe { text-align:center;}
</style>
<div class="iframe"><iframe name="$title" src="$src" 
     frameborder="0" width=750 height=750/></iframe></div>
EOHTML
}

=pod

=head1 INTERNAL ROUTINES (NON-METHODS)

These methods typically begin with two underscores (e.g., __internal_routine).

=over

=cut



1;
