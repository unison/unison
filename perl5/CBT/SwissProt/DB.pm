##############################################################################
## Nothing to modify beyond this line
##############################################################################

=head1 NAME

tflush -- hydrostatic flow controller

S<$Id: DB.pm,v 0.4 1999/06/06 21:47:21 reece Exp $>

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

BEGIN
  {
  $RCSHeader = '$Header: /mnt/cvs/cbc/opt/lib/perl5/SwissProt/DB.pm,v 0.4 1999/06/06 21:47:21 reece Exp $ ';
  print("# $RCSHeader\n") if (defined $main::DEBUG and $main::DEBUG);
  }

package CBT::SwissProt::DB;
use CBT::EBI::DB;
@ISA = qw( CBT::EBI::DB );

sub read_parse_record
  {
  my($self, $r) = @_;
  my($block);
  $block = $self->read_record($r)
	|| return(undef);
  my($record) = new CBT::SwissProt::Record;
  $record->parse_block($block);
  return($record);
  }
