
=head1 NAME

Unison::Unison -- import commonly used Unison modules

S<$Id$>

=head1 SYNOPSIS

use Unison::Unison;

=head1 DESCRIPTION

This module, B<Unison::Unison>, loads the following commonly-used
submodules in the Unison:: API.  The following are currently loaded:

=item use Unison::DBI;

=item use Unison::Exceptions;

=item use Unison::pannotation;

=item use Unison::paprospect;

=item use Unison::papseq;

=item use Unison::params;

=item use Unison::pmprospect;

=item use Unison::origin;

=item use Unison::pseq;

=item use Unison::run_history;

=item use Unison::version;


Please see these submodules for documention.

=cut

package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use Unison::DBI;
use Unison::Exceptions;
use Unison::pannotation;
use Unison::params;
use Unison::origin;
use Unison::pseq;
use Unison::run_history;
use Unison::version;

=pod

=head1 AUTHOR

 Reece Hart, Ph.D.                     rkh@gene.com, http://www.gene.com/
 Genentech, Inc.                       650/225-6133 (voice), -5389 (fax)
 Bioinformatics Department             
 1 DNA Way, MS-93                      http://www.in-machina.com/~reece/
 South San Francisco, CA  94080-4990   reece@in-machina.com, GPG: 0x25EC91A0

=cut

1;
