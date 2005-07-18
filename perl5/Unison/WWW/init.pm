=head1 NAME

Unison::template -- Unison:: module template

S<$Id: WWW.pm,v 1.12 2005/05/17 01:22:32 rkh Exp $>

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
if (q$Name:  $ =~ m/Name:\s+rel_(\S*)\s+/) { ($RELEASE = $1) =~ s/-/./g; }

1;
