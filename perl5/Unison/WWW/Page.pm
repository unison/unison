package Unison::WWW::Page;
use CGI qw(:standard *table);
our @ISA = qw(CGI);

use Unison::Exceptions;
use Unison;


sub new
  {
  my $class = shift;
  my $self = $class->SUPER::new(@_);
  my $username = $ENV{REMOTE_USER};

  # establish session authentication, preferably via kerberos
  if (defined $username and -f "/tmp/krb5cc_$username")
	{ $ENV{KRB5CCNAME}="FILE:/tmp/krb5cc_$username"; }
  else
	{ $username = 'PUBLIC'; }

  try
	{ $self->{unison} = new Unison( username=>$username, password=>undef ); }
  catch Unison::Exception::ConnectionFailed with
	{
	die($self->header(),
		$self->start_html('Unison Connection Failed'),
		"<h1>Unison Connection Failed</h1>\n",
		$_[0],
		$self->end_html());
	};
#  print(STDERR "## unison = ", $self->{unison}, "\n");
  return $self;
  }



sub start_html
  {
  my $self = shift;
  return $self->SUPER::start_html( @_,
								   -style=>{'src'=>'../unison.css'}
								 );
  }

sub render
  {
  my $p = shift;
  my $title = shift;
  return ($p->header(),
		  $p->start_html(-title=>"Unison:$title")."\n",
		  '<table class="page">',
		  '<tr>', '<td width="20%"><img valign="top"  src="../av/unison.png"></td>', "<td><b>$title</b><br>[navbar placeholder]</td>", '</tr>',
		  '<tr>', '<td width="20%" valign="top">[subnav]</td>', '<td>', @_, '</td>', '</tr>',
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
sub debug
  {
  my $p = shift;
  print $p->render("debug: $_[0]",'<span class="debug">',join('<br>',@_),'</span>');
  }
