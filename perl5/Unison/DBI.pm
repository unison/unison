=head1 NAME

Unison::DBI -- interface to the Unison database
S<$Id: DBI.pm,v 1.4 2003/05/27 22:39:23 rkh Exp $>

=head1 SYNOPSIS

 use Unison::DBI;
 my $u = new Unison::DBI;
 $u->prepare( ... );
 $u->execute( ....);

=head1 DESCRIPTION

B<Unison::DBI> provides an object-oriented interface to the Unison
database.  It provides connection defaults for public access.  It
autoloads DBI functions on-the-fly so that it can be used anywhere that a
standard DBI handle can be used.

=head1 ROUTINES & METHODS

=cut


package Unison;
use strict;
use warnings;
use Carp;
use DBI;
use Data::Dumper;
use Unison::Exceptions;


# Really, this should probably all be moved to an import subroutine (or a
# separate Unison::Options module?) which does this optionally.  By doing
# it here, we get standardized options but at the expense of prohibiting
# the use of these flags for other meanings.
use Getopt::Long;
my $p = new Getopt::Long::Parser;
$p->configure( qw(gnu_getopt pass_through) );
our %opts =
  (
   dbname => $ENV{PGDATABASE} || 'csb',
   # setting host here causes a problem: it's sometimes necessary to have
   # a NULL host setting (and 'localhost' means something else).  If we set
   # it here, there's no way to undef it.
   # host => $ENV{PGHOST} || ( `hostname` =~ m/^comp\d/ ? 'svc' : 'td-svc'),
   username => $ENV{PGUSER} || 'PUBLIC',
   password => $ENV{PGPASSWORD}
  );
our @options;
push( @options, 'dbname|d=s' => \$opts{dbname},
				'host|h=s' => \$opts{host},
				'username|U=s' => \$opts{username} );
$p->getoptions( @options );

our %attr =
  (
   PrintError => 1,
   RaiseError => 0,
   AutoCommit => 1
  );

sub new
  {
  my $type = shift;
  my %self = (%opts, @_);
  my $self = bless(\%self,$type);
  $self->connect();
  return $self;
=pod

=over

=item ::new( {<options>} );

Creates a new instance of Unison::DBI.  A connection is attempted
immediately and an exception thrown if unsuccessful.

=back

=cut
  }

sub connect
  {
  my $self = shift;
  my $dsn = shift || ("dbi:Pg:dbname=$self->{dbname}"
					  . ( defined $self->{host} ? ";host=$self->{host}" : '') );
  my $username = shift || $self->{username};
  my $pass = shift || $self->{password};
  my $attr = shift || \%attr;
  my $dbh = DBI->connect($dsn,$username,$pass,$attr);
  if (defined $dbh)
	{
	$self->{dbh} = $dbh;
	return($self);
	}
  throw Unison::Exception::ConnectionFailed( "couldn't connect to unison",
											 "dsn=$dsn\n" .
											 'username='.$self->{username}."\n" .
											 'password='.(defined $pass ?'<hidden>':'<undef>') );
  return undef;
=pod

=over

=item ::connect()

Establishes a connection to the Unison database.

=back

=cut
  }


sub DESTROY
  { $_[0]->dbh()->disconnect() if $_[0]->dbh(); }

sub dbh
  { $_[0]->{dbh} }

sub is_open
  { defined $_[0]->{'dbh'} };

sub AUTOLOAD
  {
  my $self = $_[0];
  my $method = our $AUTOLOAD;
  $method =~ s/^.*:://;
  return if $method eq 'DESTROY';
  if (defined $self->dbh()
	  and $self->dbh()->can($method))
	{
	warn("AUTOLOAD $AUTOLOAD ($self)\n") if $ENV{DEBUG};
	my $sub = "sub $AUTOLOAD "
	  . "{ \$_[0]->is_open() or throw Unison::Exception::NotConnected;"
      .   "(shift)->dbh()->$method(\@_); }";
	eval $sub;
	goto &$AUTOLOAD;
	}
  Carp::cluck("failed to AUTOLOAD $AUTOLOAD ($self)\n");
  die("$method...ooops");
  throw Unison::Exception::NotImplemented ("can't find method $method");
  }


=pod

=head1 BUGS

=head1 SEE ALSO

=head1 AUTHOR

 Reece Hart, Ph.D.                     rkh@gene.com, http://www.gene.com/
 Genentech, Inc.                       650/225-6133 (voice), -5389 (fax)
 Bioinformatics Department             
 1 DNA Way, MS-93                      http://www.in-machina.com/~reece/
 South San Francisco, CA  94080-4990   reece@in-machina.com, GPG: 0x25EC91A0

=cut

1;
