=head1 NAME

Unison::template -- Unison:: module template

S<$Id: template.pm,v 1.1 2004/05/14 20:33:19 rkh Exp $>

=head1 SYNOPSIS

 use Unison::template;
 #do something, you fool!

=head1 DESCRIPTION

B<Unison::template> is template for building new perl modules.

=cut


package Unison::WWW::NavBar;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;


=pod

=head1 ROUTINES AND METHODS

=over

=cut



######################################################################
## render

=pod

=item B<< $p->render( C<linkrefs>, C<index> ) >>

renders a NavBar, which is provided as an array reference to array
references, i.e., [ [name1,url1], [name2,url2], ... ].  C<index> is the
integer index of the link which should be highlighted.

=cut

sub render {
  ###
  my @lr = shift;							# link ref [[name,url],...]
  my $hilight = shift;						# which to highlight
  my $rv = "<table class=\"navbar\"><tr>";
  for( my $i=0; $i<=$#$lr; $i++ ) {
	my $c = 
	  $rv .= sprintf('<td%s><a href="%s">%s</a></td>',
					 ($i == $hilight-1) ? ' class="hi"' : '',
					 @{$lr->[$i]}[1,0]);
  }
  $rv .= '</tr></table>';
  return $rv;
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
