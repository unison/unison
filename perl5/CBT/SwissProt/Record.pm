##############################################################################
## Nothing to modify beyond this line
##############################################################################

=head1 NAME

tflush -- hydrostatic flow controller

S<$Id: Record.pm,v 0.4 1999/06/06 21:47:21 reece Exp $>

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

BEGIN
  {
  $RCSHeader = '$Header: /mnt/cvs/cbc/opt/lib/perl5/SwissProt/Record.pm,v 0.4 1999/06/06 21:47:21 reece Exp $ ';
  print("# $RCSHeader\n") if (defined $main::DEBUG and $main::DEBUG);
  }

package CBT::SwissProt::Record;
use CBT::EBI::Record;

@ISA = qw( CBT::EBI::Record );

sub sequence
  {
  my($self) = @_;
  my($SQ) = $self->{SQ};
  if (not defined $SQ)
	{
	warn("Record sequence undefined\n");
	return(undef);
	}
  $SQ =~ s/^.+\n//;							# delete first line
  $SQ =~ s/\s//g;							# compress spaces
  return( $SQ );
  }
