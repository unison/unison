##############################################################################
## Nothing to modify beyond this line
##############################################################################

=head1 NAME

tflush -- hydrostatic flow controller

S<$Id$>

=head1 SYNOPSIS

C<tflush [time]>

=head1 DESCRIPTION

B<tflush> 

=head1 INSTALLATION

@@banner@@

=cut

##############################################################################
## Nothing to modify beyond this line
##############################################################################

BEGIN {
    $RCSHeader =
'$Header: /usr/local/cvs/site_perl/CBT/SwissProt/DB.pm,v 1.1 2003/04/30 21:11:22 rkh Exp $ ';
    print("# $RCSHeader\n") if ( defined $main::DEBUG and $main::DEBUG );
}

package CBT::Derwent::DB;
use CBT::EBI::DB;
@ISA = qw( CBT::EBI::DB );

sub read_parse_record {
    my ( $self, $r ) = @_;
    my ($block);
    $block = $self->read_record($r)
      || return (undef);
    my ($record) = new CBT::Derwent::Record;
    $record->parse_block($block);
    return ($record);
}
