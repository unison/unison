=head1 NAME

Unison::DBI -- interface to the Unison database
S<$Id: DBI.pm,v 1.1 2003/04/28 20:52:00 rkh Exp $>

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
use DBI;
use CBT::Exceptions;
use CBT::StandardExceptions;
use Data::Dumper;


use Getopt::Long;
my $p = new Getopt::Long::Parser;
$p->configure( qw(gnu_getopt pass_through) );
our %options =
  (
   dbname => $ENV{PGDATABASE} || 'csb',
   host => $ENV{PGHOST} || ( `hostname` =~ m/^comp\d/ ? 'svc' : 'td-svc'),
   username => $ENV{PGUSER} || 'PUBLIC'
  );
our @options;
push( @options, 'dbname|d=s' => \$options{dbname},
				'host|h=s' => \$options{host},
				'username|U=s' => \$options{username} );
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
  my %self = (%options, @_);
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
  my $dsn = shift || sprintf('dbi:Pg:dbname=%s;host=%s',
							 $self->{dbname},$self->{host});
  my $username = shift || $self->{username};
  my $pass = shift || $ENV{'PGPASSWORD'};
  my $attr = shift || \%attr;
  my $dbh = DBI->connect($dsn,$username,$pass,$attr);
  if (defined $dbh)
	{
	$self->{dbh} = $dbh;
	return($self);
	}
  throw CBT::Exception::ConnectionFailed( "couldn't connect to unison",
										  "dsn=$dsn\n" .
										  'username='.$self->{username}."\n" .
										  'password='.(defined $ENV{'PGPASSWORD'}?'<pass>':'<undef>') );
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
  warn("AUTOLOAD $self->$method\n") if $ENV{DEBUG};
  $method =~ s/^.*:://;
  return if $method eq 'DESTROY';
  $self->dbh()->can($method)
	or throw CBT::Exception::NotImplemented ("can't find method $method");
  warn("AUTOLOAD thinks $self->dbh() can $method\n") if $ENV{DEBUG};
  eval "sub $AUTOLOAD { throw Exception::NotConnected unless defined \$_[0]->dbh();
                        (shift)->dbh()->$method(\@_); } ";
  goto &$AUTOLOAD;
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
