package Unison::WWW::Page;
use CGI qw(:standard *table);
our @ISA = qw(CGI);

use Unison::Exceptions;
use Unison;


sub new {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
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
								   -head =>[
											Link({-rel=>'shortcut icon',
												  -href=>'../av/favicon.png'})
										   ],
								   -style=>{'src'=>'../unison.css'}
								 );
  }

sub render
  {
  my $p = shift;
  my $title = shift;
  return ($p->header(),
		  $p->start_html(-title=>"Unison:$title")."\n",
		  '<table class="page">', "\n",
		  '<tr>', "\n",
		  '  <td class="logo" rowspan=2 width="20%"><a href="/csb/unison/"><img class="logo" src="../av/unison.png"></a></td>', "\n",
		  '  <td padding=0>', navbar2(1,['pseq','pseq.html'],['pset','pset.html']),'</td>', "\n",
		  '</tr>', "\n",
		  '<tr>', "\n", '  <td>[subnav placeholder]</td>', "\n", '</tr>',
		  '<tr>', "\n",
		  '  <td class="cnav" width="20%">[contextnav]</td>', "\n",
		  '<!-- begin page content -->', "\n",
		  '  <td>', "<b>$title</b><br>", "\n", 
		  '  ', @_, "\n",
		  '<!-- end page content -->', "\n",
		  '  </td>', "\n",
		  '<tr>', "\n",
		  '  <td class="logo"><a href="http://www.postgresql.org/"><img class="logo" src="../av/poweredby_postgresql.png"></a></td>', "\n",
		  '  <td valign="top">contact:<a href="http://gwiz/local-bin/empshow.cgi?empkey=26599">Reece Hart</a>, 
</td>', "\n",
		  '</tr>', "\n",
		  $p->end_html(),"\n");
  }


sub group
  {
  my $self = shift;
  my $name = shift;
  my $contents = shift;
  return("<table class=\"group\">\n" .
		 "<tr><th class=\"grouptag\">$name</th><th></th></tr>\n" .
		 "<tr><td colspan=\"2\">\n".$contents."\n</td></tr>\n" .
		 "</table>\n");
  }

sub ensure_required_params
  {
  my $p = shift;
  foreach my $v (@_)
	{
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
  my ($sel,@tu) = @_;
  my $rv = '<ul class="nav">';
  for(my $i=0; $i<=$#tu; $i++) {
	my $cl = (defined $sel and $sel-1 == $i) ? ' class="selected"' : '';
	$rv .= sprintf('<li%s><a href="%s">%s</a></li>',$cl,@{$tu[$i]}[1,0]);
  }
  $rv .= '</ul>';
  return $rv;
}

sub navbar2 {
  my ($sel,@tu) = @_;
  my @nav = ();
  for(my $i=0; $i<=$#tu; $i++) {
	my $cl = (defined $sel and $sel-1 == $i) ? 'selected' : 'unselected';
	push(@nav, sprintf('<td class="%s"><a href="%s">%s</a></li>',$cl,@{$tu[$i]}[1,0]));
  }
  return( '<table class="nav">',  # cellpadding=0 cellspacing=0 border=0>';
		  join('<td class="spc" width=1></td>', @nav),
		  '</table>');
}
