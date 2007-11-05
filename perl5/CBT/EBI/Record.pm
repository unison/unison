##############################################################################
## Nothing to modify beyond this line
##############################################################################

=head1 NAME

tflush -- hydrostatic flow controller

S<$Id: Record.pm,v 1.1 2003/04/30 21:11:21 rkh Exp $>

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
'$Header: /usr/local/cvs/site_perl/CBT/EBI/Record.pm,v 1.1 2003/04/30 21:11:21 rkh Exp $ ';
    print("# $RCSHeader\n") if ( defined $main::DEBUG and $main::DEBUG );
}

package CBT::EBI::Record;
use base 'CBT::Hash';

sub parse_block {
    my $self = shift;
    my $blk  = shift;
    my $prevtag;
    while ( my ( $tag, $data ) = $blk =~ /^(\w*)\s+(.+\n?)/gm ) {
        $tag = $prevtag if ( $tag eq '' );
        $self->{$tag} .= $data;
        $prevtag = $tag;
    }
    return ($self);
}

1;
