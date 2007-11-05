
=head1 NAME

Unison::Utilities::misc -- general Unison utilities

S<$Id: misc.pm,v 1.6 2006/05/12 03:39:07 rkh Exp $>

=head1 SYNOPSIS

 use Unison::Utilities::misc;

=head1 DESCRIPTION

B<Unison::Utilities::misc> is a collection of utility functions intended
primarily for use within B<Unison::> modules. However, none of these
routines are called with Unison object references (i.e., they're not
methods) and may used outside of B<Unison::>.

=cut

package Unison::Utilities::misc;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use base Exporter;
@EXPORT    = ();
@EXPORT_OK = qw/ warn_deprecated range_to_enum clean_sequence
  sequence_md5 wrap unison_logo elide_sequence
  use_at_runtime /;

use strict;
use warnings;

use Carp qw(cluck);
use Digest::MD5 qw(md5_hex);

=pod

=head1 ROUTINES AND METHODS

=over

=cut

######################################################################
## warn_deprecated

=pod

=item B<< warn_deprecated() >>

warns about the usage of a deprecated function by printing the name of the
deprecated function and backtrace.  It warns about each instance
(specifically: distinct deprecated routine and calling location) only
once; other uses within the same function, in other functions, or
elsewhere in perlspace are indicated separately.

C<warn_deprecated()> takes no arguments and infers everything it prints
from C<caller()>. It is subject to caveats in C<caller()> regarding
missing stack frame info due to optimization.

=cut

my %already_warned;

sub warn_deprecated(;$) {
    my $msg = shift;
    my ( $pkg, $fn, $line, $dep_routine ) = caller(1);
    my $instance = "$dep_routine:$fn:$line";    # defines distinct warnings
    if ( not $already_warned{$instance}++ ) {
        if ( defined $msg ) {
            chomp($msg);
            $msg = "RECOMMENDATION: $msg\n";
        }
        else {
            $msg = '';
        }
        cluck( "WARNING: $dep_routine() is deprecated\n", $msg );
    }

    #print(STDERR "warn_deprecated($instance) = $already_warned{$instance}\n");
}

######################################################################

=pod

=item B<< range_to_enum( C<range-strings> ) >>

converts an array of perl-formatted ranges as strings to an array of
individual items (typically integers). For example

range_to_enum('1..3','4,5,6..10')) returns (1,2,3,4,5,6,7,8,9,10)

=cut

sub range_to_enum (@) {
    eval join( ',', @_ );
}

######################################################################

=pod

=item B<< clean_sequence( C<sequence> ) >>

returns the sequence in a canonical format by removing non-IUPAC
characters and upcasing. This is done primarily for the purposes of
computing MD5 checksums which can be used to compare sequences
efficiently.

I<IMPORTANT:> This is not the authoritative version of C<clean_sequence()>
used by the Unison database backend.  The database implementation of this
function is written in C and is the authoritative version (see
unison/src/unison.c).  If you want the authoritative result, you may open
a database connection and use SQL like C<SELECT clean_sequence(...)>
yourself.

=cut

sub clean_sequence($) {
    my $seq = shift;
    $seq =~ s/[^-\w\*\?]//g;
    return uc($seq);
}

######################################################################

=pod

=item B<< sequence_md5( C<sequence> ) >>

"cleans" the sequences and returns the md5 checksum.

I<IMPORTANT:> sequence_md5 uses the perl implementation of clean_sequence
and therefore is subject to the same caveats as clean_sequence (see above).

=back

=cut

sub sequence_md5 ($) {
    my $seq = shift;
    return md5_hex( clean_sequence($seq) );
}

######################################################################

=pod

=item B<< wrap( C<sequence> ) >>

wraps the sequence at 60 columns

=cut

sub wrap ($) {
    my $seq = shift;
    $seq =~ s/.{1,60}/$&\n/g;
    return $seq;
}

######################################################################

=pod

=item B<< true_or_false( value ) >>

return 'true' if value is defined and non-zero, 'false' otherwise

=cut

sub true_or_false ($) {
    return 'true' if ( defined $_[0] and $_[0] ne '0' );
    return 'false';
}

######################################################################

=pod

=item B<< unison_logo( value ) >>

returns a Unison logo as a GD::Image;

=cut

sub unison_logo () {
    my ($unison_fn) = __FILE__ =~ m%^(.+)/[^/]+%;
    $unison_fn .= '/../data/unison.gif';
    return GD::Image->new($unison_fn) if ( -f $unison_fn );
    return undef;
}

######################################################################

=pod

=item B<< elide_sequence( seq, clip, gap ) >>

returns sequence, perhaps gapped with gap if longer that 2*clip+|gap|.

=cut

sub elide_sequence ($$$) {
    my ( $seq, $clip, $gap ) = @_;
    if ( length($seq) > $clip * 2 + length($gap) ) {
        $seq = substr( $seq, 0, $clip ) . $gap . substr( $seq, -$clip );
    }
    return $seq;
}

######################################################################

=pod

=item B<< use_at_runtime( module ) >>

Akin to perl's use pragma, but executes at runtime and dies if error
I haven't tried use args, such as 'use Mod qw(sub)'.

=cut

sub use_at_runtime ($) {
    eval "use @_";
    if ($@) {
        my ( $mfile, $line ) = ( caller(0) )[ 1, 2 ];
        die(
            sprintf(
                "Runtime loading of module %s failed at %s:%d:\n$@\n",
                $_[0], $mfile, $line
            )
        );
    }
}

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
