=head1 NAME

Unison::DBI -- interface to the Unison database
S<$Id: DBI.pm,v 1.15 2004/06/04 00:04:31 rkh Exp $>

=head1 SYNOPSIS

 use Unison::DBI;
 my $u = new Unison::DBI;
 $u->prepare( ... );
 $u->execute( ....);

 use Unison::pseq;
 use Unison::Exceptions;
 my $sequence;
 try {
   $sequence = $u->get_sequence_by_pseq_id( 22 );
 } catch Unison::Exception with {
   warn($_[0]);                             # print Exception and continue
 };

=head1 DESCRIPTION

B<Unison::DBI> provides an object-oriented interface to the Unison
database.  It provides connection defaults for public access.  Unison
objects may be used anywhere that a standard DBI handle can be used.

B<Unison::DBI> handles throw exceptions when SQL queries cause an
error. These errors should be trapped with Unison::Exceptions.

=head1 ROUTINES & METHODS

=cut


package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use Carp;
use DBI;
use Unison::Exceptions;


# Really, this should probably all be moved to an import subroutine (or a
# separate Unison::Options module?) which does this optionally.  By doing
# it here, we get standardized options but at the expense of prohibiting
# the use of these flags for other meanings.
use Getopt::Long;
my $parser = new Getopt::Long::Parser;
$parser->configure( qw(gnu_getopt pass_through) );

my $thishost = `hostname`; $thishost =~ s/\n$//;

our %opts =
  (
   # use PGHOST if it's not '', otherwise set based on whether we're
   # on csb (local), comp* (cvs), else exo-cluster (csb)
   # UNSET PGHOST OR SET TO '' IF YOU WANT A UNIX SOCKET CONNECTION
   host => ( (exists $ENV{PGHOST})  and ($ENV{PGHOST} =~ m/\w/) ) ? $ENV{PGHOST}
   		: $thishost =~ m/^csb/ ? 'csb'	    # local connection when possible
											# I want this to be undef, but
											# krb auth doesn't work on
											# local
		: $thishost =~ m/^comp\d/ ? 'svc'	# intra-cluster (192.168/16)
   		: 'csb',							# everywhere else

   dbname => $ENV{PGDATABASE} || 'csb',
   username => $ENV{PGUSER} || eval {my $tmp = `/usr/bin/id -un`;
									 chomp $tmp; $tmp},
   password => $ENV{PGPASSWORD},
   attr => {
			PrintError => 0,
			RaiseError => 0,
			AutoCommit => 1,
		   },
  );



our @options;
push( 
	 @options, 
	 'dbname|d=s' => \$opts{dbname},
	 'host|h=s' => \$opts{host},
	 'username|U=s' => \$opts{username}
	);
$parser->getoptions( @options );




######################################################################
## new
sub new {

=pod

=head2 ::new( {<DBI options>} );

=over

Creates a new instance of Unison::DBI.  A connection is attempted
immediately and an exception thrown if unsuccessful. See
B<Unison::connect()>. DBI options may be passed in the form of a hash, as
in:

  my $u = new Unison( username=>'rkh', dbname=>'csb-dev' );

=back

=cut

  my $type = shift;
  my %self = (%opts, @_);
  my $self = bless(\%self,$type);
  $self->connect();
  return $self;
}




######################################################################
## connect
sub connect {

=pod

=head2 ::connect( )

=over

Establishes a connection to the Unison database.

The PGUSER, PGPASSWORD, PGHOST, PGPORT, and PGDATABASE environment
variables are honored if set. If not, reasonable defaults for the
Genentech environment are used.

=back

=cut

  my $self = shift;
  if (not defined $self->{dbname}) {
	throw Unison::Exception::ConnectionFailed
	  ( "couldn't connect to Unison",
		'dbname undefined' );
  }
  if (not defined $self->{username}) {
	throw Unison::Exception::ConnectionFailed
	  ( "couldn't connect to Unison",
		'username undefined' );
  }

  my $dsn = "dbi:Pg:dbname=$self->{dbname}";
  if (defined $self->{host}) {				# never happens: host eq ''
	$dsn .= ";host=$self->{host}" ;
  }
  my $dbh = DBI->connect($dsn,
						 $self->{username},
						 $self->{password},
						 $self->{attr});
  if (not defined $dbh)	{
	throw Unison::Exception::ConnectionFailed
	  ( "couldn't connect to Unison: ",
		join("\n", 
			 'DBI ERROR: '.DBI->errstr(),
			 "dsn=$dsn",
			 'host='.(defined $self->{host} ? $self->{host} : '<undef>'),
			 'username='.(defined $self->{username} ? $self->{username} : '<undef>'),
			 'password='.(defined $self->{password} ? '<hidden>' : '<undef>')),
		'Check your settings of PGHOST (-h), PGUSER (-U), and PGDATABASE (-d)'
	  );
  }

  $dbh->{HandleError} = sub { throw Unison::Exception::DBIError ($dbh->errstr()) },
  $dbh->do('SET statement_timeout = 180000'); # 180s

  $self->{dbh} = $dbh;

  return($self);
}




######################################################################
## connect
sub DESTROY {

=pod

=head2 ::DESTROY( )

=over

disconnects from the database before destroying the database handle.

=back

=cut

  $_[0]->dbh()->disconnect() if $_[0]->dbh();
}


######################################################################
## dbh
sub dbh {

=pod

=head2 ::dbh( )

=over

returns the internal database handle

=back

=cut

  $_[0]->{dbh};
}



######################################################################
## is_open
sub is_open {

=pod

=head2 ::is_open( )

=over

returns true if a connection to the database is open.

=back

=cut

  defined $_[0]->{'dbh'}
};




######################################################################
## AUTOLOAD
sub AUTOLOAD {
  my $self = $_[0];
  my $method = our $AUTOLOAD;
  $method =~ s/^.*:://;
  return if $method eq 'DESTROY';

  # define all DBI methods on the fly as though they were
  # Unison:: methods
  if (defined $self->dbh()
	  and $self->dbh()->can($method)) {
	warn("AUTOLOAD $AUTOLOAD ($self)\n") if $ENV{DEBUG};
	## REMINDER: errors are caught by the HandleError setting above
	my $sub = <<EOF;
    sub $AUTOLOAD {
		my \$u = shift;
		\$u->is_open() or throw Unison::Exception::NotConnected;
		my \$dbh = \$u->dbh();
        \$dbh->$method(\@_);
	}
EOF
	eval $sub;
	goto &$AUTOLOAD;
  }

  # Carp::cluck("failed to AUTOLOAD $AUTOLOAD ($self)\n");
  # die("$method...ooops");
  throw Unison::Exception::NotImplemented ("can't find method $method");

=pod

=head2 ::AUTOLOAD( )

=over

autoloads any unresolved method calls to DBI.

=back

=cut

}


=pod

=head1 AUTHOR

 Reece Hart, Ph.D.                     rkh@gene.com, http://www.gene.com/
 Genentech, Inc.                       650/225-6133 (voice), -5389 (fax)
 Bioinformatics Department             
 1 DNA Way, MS-93                      http://www.in-machina.com/~reece/
 South San Francisco, CA  94080-4990   reece@in-machina.com, GPG: 0x25EC91A0

=cut

1;
