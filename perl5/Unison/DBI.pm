=head1 NAME

Unison::DBI -- interface to the Unison database
S<$Id: DBI.pm,v 1.12 2004/05/06 22:39:56 rkh Exp $>

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
my $p = new Getopt::Long::Parser;
$p->configure( qw(gnu_getopt pass_through) );

my $thishost = `hostname`; $thishost =~ s/\n$//;

our %opts =
  (
   # use PGHOST if it's not '', otherwise set based on whether we're
   # on csb (local), comp* (cvs), else exo-cluster (csb)
   # UNSET PGHOST OR SET TO '' IF YOU WANT A UNIX SOCKET CONNECTION
   host => ( (exists $ENV{PGHOST})  and ($ENV{PGHOST} =~ m/\w/) ) ? $ENV{PGHOST}
   		: $thishost =~ m/^csb/ ? 'csb'	    # local connection when possible
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
push( @options, 'dbname|d=s' => \$opts{dbname},
				'host|h=s' => \$opts{host},
				'username|U=s' => \$opts{username} );
$p->getoptions( @options );




sub new {
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

=pod

=over

=item ::connect()

Establishes a connection to the Unison database.

=back

=cut
}


sub DESTROY {
  $_[0]->dbh()->disconnect() if $_[0]->dbh();
}

sub dbh {
  $_[0]->{dbh};
}

sub is_open {
  defined $_[0]->{'dbh'}
};


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
