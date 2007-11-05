#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long qw(:config gnu_getopt);

use CBT::Exceptions;

use lib '.';
use MyModule;

# GetOptions.  For simplicity, NOT done with exceptions
my %options;
GetOptions( \%options, 'catch|c+', 'debug|d+' )
  || die( 'missing argument (0-4)', "try $0 --help" );

@ARGV = ( 1, 2, 3, 4, 0 ) unless @ARGV;

sub cleanup  { warn("cleaning up...\n\n"); }
sub proc1($) { proc2( $_[0] ); }
sub proc2($) { MyModule::think( $_[0] ); }

if ( $options{catch} ) {
    foreach my $s (@ARGV) {
        print STDERR "about to try & catch (s=$s)\n";
        try { proc1($s); }
        catch CBT::Exception with {
            warn("catch'ing exceptions (s=$s)...\n");
            my $ex = shift;
            warn $ex;
        }
        finally {
            warn("finally'ing (s=$s)...\n");
            cleanup();
        };
    }
}
else {
    foreach my $s (@ARGV) {
        print STDERR "about to execute (without catching)\n";
        proc1($s);
    }
}

exit(0);

