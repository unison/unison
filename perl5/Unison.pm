=head1 NAME

Unison -- Unison database API for perl

S<$Id: Unison.pm,v 1.13 2005/03/21 15:54:43 rkh Exp $>

=head1 SYNOPSIS

 use Unison;

=head1 DESCRIPTION

The B<Unison::> perl modules implement a perl API to the Unison database.

C<use Unison;> really loads Unison::common, which in turn loads the most
commonly used Unison modules. See Unison::common for more information.

Modules currently available are:

=over

=item Unison::blat

=item Unison::common

=item Unison::DBI

=item Unison::Exceptions

=item Unison::genome_features

=item Unison::palias

=item Unison::paprospect2

=item Unison::papseq

=item Unison::params

=item Unison::pmprospect2

=item Unison::porigin

=item Unison::pseq

=item Unison::pseq_features

=item Unison::run_history

=item Unison::SQL

=item Unison::template

=item Unison::userprefs

=back

d28 1

=cut


package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

our ($RELEASE) = q$Name:  $ =~ m/Name:\s+(\S*)\s+/;
if (q$Name:  $ =~ m/Name:\s+rel_(\S*)\s+/) { ($RELEASE = $1) =~ s/-/./g; }

use Unison::common;


=pod

=head1 SEE ALSO

=over

=item perldoc Unison::intro

=item perldoc Unison::common

=back

=head1 AUTHOR

 Reece Hart, Ph.D.                      rkh@gene.com, http://www.gene.com/
 Genentech, Inc.                        650-225-6133 (voice), -5389 (fax)
 Bioinformatics and Protein Engineering
 1 DNA Way, MS-93                       http://harts.net/reece/
 South San Francisco, CA  94080-4990    reece@harts.net, GPG: 0x25EC91A0

=cut

1;
