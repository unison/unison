#!  /usr/bin/env perl

use warnings;
use strict;
use Bio::Tools::BPlite;
use Unison;

$ENV{DEBUG}=1;
die( "USAGE: blastfeature.pl <pseq_id> <blast output>\n" ) if $#ARGV != 1;
my $u = new Unison( 'username' => 'admin', 'dbname' => 'csb-dev','password' => $ENV{'PGPASSWD'} );
my $q_pseq_id = $ARGV[0];
my $file = $ARGV[1];

my $report = new Bio::Tools::BPlite(-file=>$file);
while(my $sbjct = $report->nextSbjct) {
  $sbjct->name =~ m/^(.*?) /;
  my $t_pseq_id = $u->get_pseq_id_from_alias( $1 );
  if ( !defined $t_pseq_id ) {
    warn("no pseq_id defined for target sequence: $1 - skipping\n" );
    next;
  }
  while(my $hsp = $sbjct->nextHSP) {
    $u->insert_hsp( $q_pseq_id, $t_pseq_id, $hsp );
  }
}
