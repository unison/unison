=head1 NAME

Unison::DBI -- interface to the Unison database
S<$Id: DBI.pm,v 1.7 2003/10/09 16:59:30 rkh Exp $>

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

my $hostname = `hostname`;
our %opts =
  (
   # use PGHOST if it's not '', otherwise set based on whether we're
   # on interceptor (local), comp* (svc), else exocluster (td-svc)
   # IF PGHOST IS SET AND YOU WANT A UNIX SOCKET CONNECTION,
   # you'll need to unset PGHOST first.
   host => ( exists $ENV{PGHOST}
			 ? ( $ENV{PGHOST} ne '' ? $ENV{PGHOST} : undef )
			 : ( $hostname eq 'interceptor'
				 ? undef
				 : ( $hostname =~ m/^comp\d/ ? 'svc' : 'td-svc' ))),
   dbname => $ENV{PGDATABASE} || 'csb',
   username => $ENV{PGUSER} || 'PUBLIC',
   password => $ENV{PGPASSWORD} || undef,
   attr => {
			PrintError => 1,
#			RaiseError => 1,
			AutoCommit => 1
		   },
  );


our @options;
push( @options, 'dbname|d=s' => \$opts{dbname},
				'host|h=s' => \$opts{host},
				'username|U=s' => \$opts{username} );
$p->getoptions( @options );



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

sub connect {
  my $self = shift;
  my $dsn = "dbi:Pg:dbname=$self->{dbname}";
  $dsn .= ";host=$self->{host}" if (defined $self->{host} and $self->{host} ne '');
  my $dbh = DBI->connect($dsn,
						 $self->{username},
						 $self->{password},
						 $self->{attr});
  if (not defined $dbh)	{
	throw Unison::Exception::ConnectionFailed( "couldn't connect to unison",
											   "dsn=$dsn\n" .
											   'username='.$self->{username}."\n" .
											   'password='.(defined $self->{password} ?
															'<hidden>' : '<undef>'),
											   'Check your settings of PGHOST (-h), PGUSER (-U), and PGDATABASE (-d)'
											 );
  }

  $self->{dbh} = $dbh;
  return($self);

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
