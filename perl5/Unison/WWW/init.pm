
=head1 NAME

Unison::template -- Unison:: module template

S<$Id: init.pm,v 1.1 2005/07/18 20:32:57 rkh Exp $>

=head1 SYNOPSIS

 use Unison::template;
 #do something, you fool!

=head1 DESCRIPTION

B<Unison::template> is template for building new perl modules.

=cut

package Unison::WWW;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

our $RELEASE = '';
if (q$HeadURL$ =~ m/tags\/rel_(\S*?)\//) { ($RELEASE = $1) =~ s/-/./g;}

use Unison::WWW::Config;

1;
