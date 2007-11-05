
=head1 NAME

Unison::template -- Unison:: module template

S<$Id$>

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
if (q$HeadURL: https://unison-db.svn.sourceforge.net/svnroot/unison-db/trunk/perl5/Unison/WWW/init.pm $ =~ m/tags\/rel_(\S*?)\//) { ($RELEASE = $1) =~ s/-/./g;}

use Unison::WWW::Config;

1;
