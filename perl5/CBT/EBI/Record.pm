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
  $RCSHeader = '$Header: /mnt/cvs/cbc/opt/lib/perl5/EBI/Record.pm,v 0.4 1999/06/06 21:47:21 reece Exp $ ';
  print("# $RCSHeader\n") if (defined $main::DEBUG and $main::DEBUG);
  }

package CBT::EBI::Record;
use base 'CBT::Hash';

sub parse_block
  {
  my($self) = shift;
  local($_) = shift;
  my($prevtag) = 'NO SUCH TAG';
  while( /^(\w*)\s+(.+\n?)/gm )
	{
	my($tag,$data) = ($1,$2);
	$tag = $prevtag if ($tag eq '');
	$self->{$tag} .= $data;
	$prevtag = $tag;
	}
  return($self);
  }

1;
