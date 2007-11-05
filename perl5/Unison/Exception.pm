
=head1 NAME

Unison::Exception -- base class for exceptions
S<$Id: Exception.pm,v 1.1 2007/02/10 00:58:47 rkh Exp $>

=head1 SYNOPSIS

 package MyModule::Exception;
 use base Unison::Exception;

 package MyModule;
 ...
 if ($failed)
   { throw MyModule::Exception; }
 ...


=head1 DESCRIPTION

B<Unison::Exception> is a base class for exceptions.  It may be used
as-is or as a base class for other exceptions.  It is based on Error.pm
with enhancements for providing more informative feedback and run-time
control of feedback levels.

At the time of this writing, one really needs two components to use
exceptions: 1) an exception class, 2) the language extensions which enable
the try...catch...finally syntax.  This module provides a base class for
(1); `use Unison::Exceptions' for (2).

A B<Unison::Exception> instance has these attributes:

=over 4

=item error

error is a short (1 line) description of the problem.  Consider using $!
if nothing else.

=item detail (optional)

detail provides more details about the nature of the problem.  The
contents of this field are word-wrapped.

=item advice (optional)

advice provides advice about how to rememdy the error.  The contents of
this field are word-wrapped.

=back 4

When thrown, a B<Unison::Exception> looks like this:

 ! MyModule::Exception occurred: invalid argument
 Detail: you provided 0 for your IQ; the valid range is 1..10
 Advice: soak your head

=head1 ROUTINES & METHODS

=cut

package Unison::Exception;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

our ($VERSION) = q$Revision: 1.1 $ =~ m/Revision: ([\d\.]+)/;

use base qw(Error);
use Text::Wrap qw(wrap);
use Carp;

our $show_stacktrace = $CBT::debug || $ENV{EX_STACKTRACE} || 0;
our $show_advice = exists $ENV{EX_ADVICE} ? $ENV{EX_ADVICE} : 1;

sub new {
    my $class = shift;
    my %ex;
    if ( ref $_[0] ) {    # throw Ex ( {...} )
        %ex = %{ $_[0] };
        $ex{error} = $ex{text} if not exists $ex{error} and exists $ex{text};
    }
    else {                # throw Ex (  ...  )
        $ex{error}  = shift if @_;
        $ex{detail} = shift if @_;
        $ex{advice} = shift if @_;
    }

    if ( not defined $ex{error} ) {
        if ($!) {
            $ex{error} = $!;
        }
        else {
            croak("Exception created without error string\n") if $ENV{DEBUG};
            $ex{error} = 'unknown error';
        }
    }

    #$ex{detail} = $! if (not defined $ex{detail} and $!);

    local $Error::Debug =
      exists $ex{stacktrace} ? $ex{stacktrace} : $show_stacktrace;
    local $Error::Depth = $Error::Depth + 1;

    my $self = $class->SUPER::new( %ex, @_ );
    return $self;

=pod

=over

=item B<::new( {error=E<gt>...,
                detail=E<gt>...,
                advice=E<gt>...} )>

=item B<::new( error, detail, advice )>

creates a new exception with the spe

=back

=cut

}

=pod

=over

=item B<::error( [B<error text>] )

=item B<::detail( [B<detail text>] )

=item B<::advice( [B<advice text>] )

Accessors (set/get) for the error, detail, and advice fields.

=back

=cut

sub error($;$)  { $_[0]->{error}  = $_[1] if $#_ == 1; $_[0]->{error}; }
sub detail($;$) { $_[0]->{detail} = $_[1] if $#_ == 1; $_[0]->{detail}; }
sub advice($;$) { $_[0]->{advice} = $_[1] if $#_ == 1; $_[0]->{advice}; }

## INTERNAL FUNCTIONS
sub stringify($) {
    my $self = shift;
    my $r =
      "! " . ( ref($self) || $self ) . " occurred: " . $self->error() . "\n";
    if ( $self->detail() ) {
        $r .= "Detail:" . __wrap( $self->detail() ) . "\n";
    }
    if ( $show_advice and $self->advice() ) {
        $r .= "Advice:" . __wrap( $self->advice() ) . "\n";
    }
    if ($show_stacktrace) {
        $r .= "Trace:\t" . $self->stacktrace() . "\n";
    }
    return $r;
}

sub __wrap($) {
    my $t = shift;
    return Text::Wrap::wrap( "\t", "\t", $t );
}

# backward compatibility
sub text($) { $_[0]->error(); }

1;

=pod

=head1 SEE ALSO

Error.pm -- where all the hard work's done

=head1 AUTHOR

 Reece Hart E<lt>reece@in-machina.comE<gt>
 http://www.in-machina.com/~reece/

=cut

## TODO-
## -- on-the-fly exception class creation, e.g.,
##    throw YetUnamedException ('you blew it') by overloading throw?
## -- consider carefully which exception classes to generate
##    perhaps Dave could research this, using java and python as examples
## -- -level field to control severity w/ run-time control of
##    warning level and fatal level thresholds.
