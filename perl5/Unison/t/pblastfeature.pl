#!  /usr/bin/env perl

use warnings;
use strict;
use Bio::Tools::BPlite;
use Data::Dumper;
use Unison;

$ENV{DEBUG}=1;
die( "USAGE: pblastfeature.pl <pseq_id> <blast output>\n" ) if $#ARGV != 1;
my $u = new Unison( 'username' => 'admin', 'dbname' => 'csb-dev','password' => $ENV{'PGPASSWD'} );
#my $q_pseq_id = $ARGV[0];
my $file = $ARGV[1];

my $report = new Bio::Tools::BPlite(-file=>$file);
my $q_pseq_id = _get_pseq_id_from_name( $u, $report->query() );
if ( !defined $q_pseq_id ) {
	warn("no pseq_id defined for query sequence: $1 - skipping\n" );
	next;
}
while(my $sbjct = $report->nextSbjct) {
  my $t_pseq_id = _get_pseq_id_from_name($u,$sbjct->name());
  if ( !defined $t_pseq_id ) {
    warn("no pseq_id defined for target sequence: " . $sbjct->name() . " - skipping\n" );
    next;
  }
  while(my $hsp = $sbjct->nextHSP) {
    $u->insert_hsp( $q_pseq_id, $t_pseq_id, $hsp );
  }
}

sub _get_pseq_id_from_name {
	my ($u,$name) = @_;
	my $pseq_id;
	print "finding pseq_id for $name\n";
	if ( $name =~ m/^Unison:(\d+)/ ) {
		$pseq_id=$1;
	} else {
	  $name =~ m/^(.*?)\s/;
		my $alias = $1;
		$pseq_id = $u->get_pseq_id_from_alias( $alias );
	}
	print "found $pseq_id\n";
	return $pseq_id;
}
