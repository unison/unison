##############################################################################
## Nothing to modify beyond this line
##############################################################################

=head1 NAME

tflush -- hydrostatic flow controller

S<$Id$>

=head1 SYNOPSIS

C<tflush [time]>

=head1 DESCRIPTION

B<tflush> flushes toilet remotely in case you realize that you forgot this

=head1 INSTALLATION

@@banner@@

=cut

##############################################################################
## Nothing to modify beyond this line
##############################################################################

BEGIN {
    $RCSHeader =
'$Header: /usr/local/cvs/site_perl/CBT/SwissProt/Record.pm,v 1.1 2003/04/30 21:11:22 rkh Exp $ ';
    print("# $RCSHeader\n") if ( defined $main::DEBUG and $main::DEBUG );
}

package CBT::Derwent::Record;
use base 'CBT::EBI::Record';

sub sequence {
    my ($self) = @_;
    my ($SQ)   = $self->{SQ};
    if ( not defined $SQ ) {
        warn("Record sequence undefined\n");
        return (undef);
    }
    $SQ =~ s/^.+\n//;    # delete first line
    $SQ =~ s/\s//g;      # compress spaces
    return ($SQ);
}

1;
