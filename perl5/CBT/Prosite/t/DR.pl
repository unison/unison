#!/usr/bin/env perl

use lib '../..';
use CBT::Prosite::DB;
use CBT::Prosite::Record;


# open database
my $dbfn = shift;
my $db = new CBT::Prosite::DB;
$db->open("$dbfn")
  || die("$dbfn: $!\n");

# read records
while( defined (my $AC = shift) )
  {
  my($r);
  if (not defined ($r = $db->read_parse_record($AC)) )
	{ warn("$AC: couldn't read record\n"); next; }
  my(@T)  = $r->all_positives;     my $T  = $#T+1;  my $nT  = ($r->nTotal)[1];
  my(@TP) = $r->true_positives;	   my $TP = $#TP+1; my $nTP = ($r->nTruePositive)[1];
  my(@FP) = $r->false_positives;   my $FP = $#FP+1; my $nFP = ($r->nFalsePositive)[1];
  my(@UP) = $r->unknown_positives; my $UP = $#UP+1; my $nUP = ($r->nUnknownPositive)[1];
  my(@FN) = $r->false_negatives;   my $FN = $#FN+1; my $nFN = $r->nFalseNegative;
  my(@P)  = $r->potentials;		   my $P  = $#P+1;  my $nP  = $r->nPartial;
  printf("$AC T:%4d/%4d%s TP:%4d/%4d%s FP:%4d/%4d%s UP:%4d/%4d%s FN:%4d/%4d%s P:%4d/%4d%s\n",
		 $nT , $T , x($nT -$T ),
		 $nTP, $TP, x($nTP-$TP),
		 $nFP, $FP, x($nFP-$FP),
		 $nUP, $UP, x($nUP-$UP),
		 $nFN, $FN, x($nFN-$FN),
		 $nP , $P , x($nP -$P ) );
  }
$db->close();

sub x { $_[0] ? '*' : ' ' }
