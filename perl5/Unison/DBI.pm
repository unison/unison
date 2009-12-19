
=head1 NAME

Unison::DBI -- interface to the Unison database
S<$Id$>

=head1 SYNOPSIS

 use Unison;
 my $u = new Unison;
 $u->prepare( ... );
 $u->execute( ... );

=head1 DESCRIPTION

B<Unison::DBI> provides an object-oriented interface to the Unison
database.  It provides connection defaults for public access.  Unison
objects may be used anywhere that a standard DBI handle can be used.

B<Unison::DBI> handles throw exceptions subclassed from
B<Unison::Exception> when the underlying DBI fails.

=cut

# TODO:
# - The entire connection setup needs an overhaul to accommodate multiple
# installation environments.  This requires a saner way to sniff out where
# we're running or to just resign ourselves to requiring local
# configuration (or an optional config that overrides the guesses).


package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use Carp;
use DBI;
use Unison::Exceptions;
use Getopt::Long;

#use lib '/gne/research/apps/bioperl/prd/lib/perl5';

our %opts = (
    host 		=> (
					( ( exists $ENV{PGHOST} ) and ( $ENV{PGHOST} =~ m/\w/ ) )
					 ? $ENV{PGHOST}
					 : (
						(`dnsdomainname` =~ m/^gene\.com$/ or `hostname` =~ m/gene\.com$/) # Genentech
						? 'respgsql' 
						: 'unison-db.org'
					   )
				   ),
    dbname 		=> $ENV{PGDATABASE} 
	                                 ||((`dnsdomainname` =~ m/^gene\.com$/ or `hostname` =~ m/gene\.com$/) 
			                 ? 'csb'
			                 : 'unison'),
    username 	=> $ENV{PGUSER}   || eval {my $tmp = `/usr/bin/id -un`;
										   chomp $tmp;
										   $tmp;
										 },
    password 	=> $ENV{PGPASSWORD},
    attr     	=> {
					# we should migrate to AutoCommit => 0, but this requires
					# coordination with loading clients
					AutoCommit => 1,
					PrintError => 0,
					RaiseError => 0,

					# Does the following work as an alternative to
					# setting HandleError explicitly below?
					# HandleError = sub { throw Unison::Exception::DBIError ($dbh->errstr()) },
				   },
);


# Really, this should probably all be moved to an import subroutine (or a
# separate Unison::Options module?) which does this optionally.  By doing
# it here, we get standardized options but at the expense of prohibiting
# the use of these flags for other meanings.
our @options;
push(
    @options,
    'dbname|d=s'   => \$opts{dbname},
    'host|h=s'     => \$opts{host},
    'username|U=s' => \$opts{username}
);

my $parser = new Getopt::Long::Parser;
$parser->configure(qw(gnu_getopt pass_through));
$parser->getoptions(@options);

=pod

=head1 ROUTINES & METHODS

=over

=cut

######################################################################
## new

=pod

=item ::new( {<DBI options>} );

Creates a new instance of Unison::DBI.  A connection is attempted
immediately and an exception thrown if unsuccessful. See
B<Unison::connect()>. DBI options may be passed in the form of
a hash, as in:

  my $u = new Unison( username=>'rkh', dbname=>'csb-dev' );

=cut

sub new {
    my $type = shift;
    my %self = ( %opts, @_ );
    my $self = bless( \%self, $type );
    $self->connect();
    return $self;
}

######################################################################
## connect

=pod

=item ::connect( )

Establishes a connection to the Unison database.

The PGUSER, PGPASSWORD, PGHOST, PGPORT, and PGDATABASE environment
variables are honored if set. If not, reasonable defaults for the
Genentech environment are used.

=cut

sub connect {
    my $self = shift;

	$self->{host}     = 'unison-db.org' unless defined $self->{host};
	$self->{dbname}   = 'unison'        unless defined $self->{dbname};
    $self->{username} = 'PUBLIC'        unless defined $self->{username};

    my $dsn = sprintf('dbi:Pg:host=%s;dbname=%s',$self->{host},$self->{dbname});
    my $dbh = DBI->connect( $dsn,
							$self->{username}, $self->{password},
							$self->{attr} );
    if ( not defined $dbh ) {
        throw Unison::Exception::ConnectionFailed(
            "couldn't connect to Unison: ",
            join(
                "\n",
                'DBI ERROR: ' . DBI->errstr(),
                "dsn=$dsn",
                'host='
                    . ( defined $self->{host} ? $self->{host} : '<undef>' ),
                'username='
                    . (
                    defined $self->{username} ? $self->{username} : '<undef>'
                    ),
                'password='
                    . ( defined $self->{password} ? '<hidden>' : '<undef>' )
            ),
            <<EOT);
Please ensure that you have a valid Kerberos ticket, or check
your settings of PGHOST (-h), PGUSER (-U), and PGDATABASE
(-d). To check for a valid Kerberos ticket, type 'klist'. To
get a Kerberos ticket, type 'kinit'.
EOT
    }

    # ALL DBI errors should be handled by Unison::Exception::DBIError
    $dbh->{HandleError}
        = sub { throw Unison::Exception::DBIError( $dbh->errstr() ) };

    $self->{dbh} = $dbh;

    return ($self);
}

######################################################################
## connect

=pod

=item ::DESTROY( )

Disconnects from the database before destroying the database handle.

=cut

sub DESTROY {
    $_[0]->dbh()->disconnect() if $_[0]->dbh();
}

######################################################################
## dbh

=pod

=item ::dbh( )

returns the internal database handle

=cut

sub dbh {
    $_[0]->{dbh};
}

######################################################################
## is_open

=pod

=item ::is_open( )

returns true if a connection to the database is open.

=cut

sub is_open {
    defined $_[0]->{'dbh'};
}

######################################################################
## AUTOLOAD

=pod

=item ::AUTOLOAD( )

AUTOLOAD is the basis for providing the appearance of a Unison instance as
a subclass of DBI. Any method which is not explicitly provided by any of
the Unison:: modules is passed to DBI, if such a method exists. In order
to make subsequent calls to the same method faster, AUTOLOAD defines a
shadow method on-the-fly.

=cut

sub AUTOLOAD {
    my $self   = $_[0];
    my $method = our $AUTOLOAD;
    $method =~ s/^.*:://;
    return if $method eq 'DESTROY';

    confess("AUTOLOAD called on undefined object!\n\t")
        if ( not defined $self );

    # define all DBI methods on the fly as though they were
    # Unison:: methods
    if ( defined $self->dbh()
        and $self->dbh()->can($method) )
    {
        warn("AUTOLOAD $AUTOLOAD ($self)\n") if $ENV{DEBUG};
        my $tracer = '';
		#$tracer = 'print($method,"\n");' if ($method =~ m/^(?:begin_work|commit|end|rollback)$/);
        ## REMINDER: errors are caught by the HandleError setting above
        my $sub = <<EOF;
    sub $AUTOLOAD {
		my \$u = shift;
        $tracer
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
    throw Unison::Exception::NotImplemented("can't find method $method");
}

######################################################################

=pod

=item B<< is_public_instance( ) >>

returns 1 if this is a public database, per meta table

=cut

sub is_public_instance ($) {
    my $self = shift;
    if ( not defined $self->{is_public_instance} ) {
	  $self->{is_public_instance}
		= $self->selectrow_array( <<EOSQL );
SELECT CASE 
  WHEN EXISTS (SELECT * FROM meta WHERE key='publicized by') THEN 1
  ELSE 0
END;
EOSQL
    }
    return $self->{is_public_instance};
}
sub is_public { goto &is_public_instance; }

######################################################################

=pod

=item B<< is_prd_instance( ) >>

returns 1 if this is a production database, per meta table

=cut

sub is_prd_instance ($) {
    my $self = shift;
    if ( not defined $self->{is_prd_instance} ) {
        $self->{is_prd_instance}
            = $self->selectrow_array( <<EOSQL );
SELECT CASE
  WHEN EXISTS (SELECT * FROM meta WHERE key='released on') THEN 1
  ELSE 0
END;
EOSQL
    }
    return $self->{is_prd_instance};
}

######################################################################

=pod

=item B<< release_timestamp( ) >>

returns the release timestamp for this database, or undef if this
database hasn't been released.

=cut

sub release_timestamp ($) {
    my $self = shift;
    if ( not defined $self->{release_timestamp} ) {
        $self->{release_timestamp} = $self->selectrow_array(
            'select value::date from meta where key=\'release timestamp\'');
    }
    return $self->{release_timestamp};
}

=pod

=back

=head1 BUGS

Please report bugs to Reece Hart E<lt>hart.reece@gene.comE<gt>.

=head1 SEE ALSO

=over 4

=item * perldoc Unison

=item * perldoc Unison::Exceptions

=back

=head1 AUTHOR

see C<perldoc Unison> for contact information

=cut

1;
