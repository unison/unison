
=head1 NAME

Unison::options -- Unison:: standardized option processing

S<$Id$>

=head1 SYNOPSIS

 use Unison::options;

=head1 DESCRIPTION

B<Unison::options> standardizes command-line arguments for Unison perl
modules.

=cut

package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;
use Getopt::Long;

our %opts = (
    # use PGHOST if it's not '', otherwise set based on whether we're
    # NOTE: Set PGHOST to '' if you want a Unix socket connection
    host => ( ( exists $ENV{PGHOST} ) and ( $ENV{PGHOST} =~ m/\w/ ) )
    ? $ENV{PGHOST}
    : 'respgsql',

    # by default, use the production db
    dbname => $ENV{PGDATABASE} || 'csb',

    # by default, connect as the invoking user
    username => $ENV{PGUSER}
      || eval { my $tmp = `/usr/bin/id -un`; chomp $tmp; $tmp },

    # PGPASSWORD may be unset (as for kerberos authentication)
    password => $ENV{PGPASSWORD},

    # DBI options
    attr => {
        PrintError => 0,
        RaiseError => 0,
        AutoCommit => 1,

     # FIXME: does the following work?
     # HandleError = sub { throw Unison::Exception::DBIError ($dbh->errstr()) },
    },
);

my @options = (
    'dbname|d=s'   => \$Unison::opts{dbname},
    'host|h=s'     => \$Unison::opts{host},
    'username|U=s' => \$Unison::opts{username}
);

my $parser = new Getopt::Long::Parser;
$parser->configure(qw(gnu_getopt pass_through));
$parser->getoptions(@options);

=pod

=back

=head1 BUGS

Please report bugs to Reece Hart E<lt>hart.reece@gene.comE<gt>.

=head1 SEE ALSO

=over 4

=item * perldoc Unison

=back

=head1 AUTHOR

see C<perldoc Unison> for contact information

=cut

1;
