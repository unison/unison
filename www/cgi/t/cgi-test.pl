#! /usr/bin/env perl
# cgi-test -- test Unison cgis
# You must be sitting in the CGI directory you wish to test.
# $Id: cgi-test.pl,v 1.3 2005/07/25 22:13:33 rkh Exp $

use warnings;
use strict;
use Getopt::Long;
use Benchmark ':hireswallclock';


my $usage = <<'EOU';
#-------------------------------------------------------------------------------
# NAME    : page_test
# PURPOSE : test cgi scripts under Unison web tree
# USAGE   : page_test OPTIONS
# OPTIONS :
#       -h  <host>    # unison host machine name
#       -db <dbname>  # database name to connect to
#       -q  <pseq_id> # pseq_id commonly used for testing
#       -v            # verbose option to see the commnd line used for testing
# $Id: cgi-test.pl,v 1.3 2005/07/25 22:13:33 rkh Exp $
#------------------------------------------------------------------------------

EOU

my %opts = (
	    verbose  => 0,
	    host    => 'csb',
	    dbname  => 'csb-dev',
	    pseq_id => 76
	   );

GetOptions(\%opts,
	   'verbose|v',
	   'query|q=i',
	   'dbname|db=s',
	   'host|h=s',
	   'help'
)  || die("$0: Incorrect Usage\n");

die "$usage" if ($opts{help});


if (defined $ENV{HTTP_HOST}) {
  print <<EOT;
Content-type: text/html

<html><body><pre>
EOT
}


select(STDERR); $|++;
select(STDOUT); $|++;

if (defined $ENV{HTTP_HOST}) {
  printf("Content-type: text/plain\n\n");
}

my $pseq_id = $opts{pseq_id};

my @cgi_scripts =
  (
   ['control'],
   #
   ['about_contents'],
   ['about_credits'],
   ['about_env'],
   ['about_prefs'],
   ['about_unison'],
   ['browse_sets',"pset_id=1047"],
   ['browse_views',"cv_id=4"],
   ['chr_view',"chr=3 gstart=173540198 gstop=173567087"],
   ['compare_methods',"submit=vroom pmodelset_id=3 pcontrolset_id=500 params_id=1 score=raw"],
   ['compare_scores',"submit=vroom pmodelset_id=3 pcontrolset_id=500 params_id=1 score=svm Plot=Scatter"],
   ['compare_scores',"submit=vroom pmodelset_id=3 pcontrolset_id=500 params_id=1 score=svm Plot=Range"],
   ['compare_scores',"submit=vroom pmodelset_id=3 pcontrolset_id=500 params_id=1 score=svm Plot=Clustered"],
   ['compare_scores',"submit=vroom pmodelset_id=13 pcontrolset_id=500 params_id=1 score=raw Plot=Scatter"],
   ['compare_scores',"submit=vroom pmodelset_id=13 pcontrolset_id=500 params_id=1 score=raw Plot=Range"],
   ['compare_scores',"submit=vroom pmodelset_id=13 pcontrolset_id=500 params_id=1 score=raw Plot=Clustered"],
   ['genome_features',"genasm_id=1 chr=15 gstart=39562512 gstop=39591527"],
   ['get_fasta',"pseq_id=$pseq_id"],
   ['hmm_alignment',"pseq_id=$pseq_id profiles=TNF params_id=15"],
   ['p2alignment',"pseq_id=76 params_id=1 templates=1jtzx"],
   ['p2cm',"pseq_id=$pseq_id viewer=rasmol params_id=1 templates=1jtzx"],
   ['pseq_blast',"pseq_id=$pseq_id"],
   ['pseq_features',"pseq_id=$pseq_id"],
   ['pseq_history',"pseq_id=$pseq_id"],
   ['pseq_loci',"pseq_id=$pseq_id"],
   ['pseq_intx',"pseq_id=94893"],
   ['pseq_notes',"pseq_id=231"],
   ['pseq_pahmm',"pseq_id=$pseq_id"],
   ['pseq_paliases',"pseq_id=$pseq_id"],
   ['pseq_paprospect2',"pseq_id=$pseq_id"],
   ['pseq_papssm',"pseq_id=$pseq_id"],
   ['pseq_patents',"pseq_id=$pseq_id"],
   ['pseq_structure',"pseq_id=$pseq_id"],
   ['pseq_summary',"pseq_id=$pseq_id"],
   ['search_by_alias',"alias=EGFR_HUMAN"],
   ['search_by_properties',"o_sel=GenenGenes o_sel=Incyte o_sel=ProAnno+v1 o_sel=Proteome o_sel=RefSeq o_sel=Swiss-Prot r_species=on r_species_sel=9606 r_age_sel=30d r_len=on r_len_min=100 r_len_max=400 r_sigp=on r_sigp_sel=0.6 al_hmm_eval=1e-10 al_pssm_eval=1e-10 al_prospect2=on al_prospect2_svm=9 al_prospect2_params_id=1 al_ms_sel=2 al_go_sel=5164 x_set_sel=5 submit=vroom"],
   ['search_framework'],
   ['search_sets',"ubmit=vroom pset_id=5 pmodelset_id=3 hmm=on hmm_params_id=15 hmm_eval=1e-10 pssm=on pssm_params_id=8 pssm_eval=1e-10 prospect2=on prospect2_params_id=1 prospect2_svm=12"],
  );

my @badwords = ('Server Error', 'Object not found', 'DBIError', 'Exception');
my @goodwords = ('html');
my $passed =  0;

print "script\t\t\t\t\tpassed\tfailed\ttime\n";

print "==============================================================\n";
foreach (@cgi_scripts) {
  my $message = '';
  my $failed = 0;
  my $cmd = "../$_->[0].pl host=$opts{host} dbname=$opts{dbname}";
  $cmd .= " $_->[1]" if(defined($_->[1]));
  $cmd .= " 2>&1";
  print "$cmd\n" if($opts{verbose});

  print "$_->[0] ", "." x (30-length("$_->[0]"));
  my $t0 = new Benchmark;
  my $output = `$cmd 2>&1`;
  my $t1 = new Benchmark;
  my $time = @{timediff($t1, $t0)}[0];

  if ($?) {
	$message = $!;
	$failed++;
  } else {
	foreach (@badwords) {
	  if ($output =~ /\b$_\b/i and $output !~ /$_.pm/) {
		$message = $_;
		$failed++;
		last;
	  }
	}
	foreach (@goodwords) {
	  if (not $output =~ /$_/i) {
		$failed++;
		$message = "missing $_";
	  }
	}
  }

  if ($failed) {
	print " :\t\tFAILED ($message)\n";
  } else {
    $passed++;
    printf( " :\tPASSED\t\t%5.2fs\n",$time);
  }
}

print "Total Passed = $passed / ",$#cgi_scripts+1,"\n";


if (defined $ENV{HTTP_HOST}) {
  print <<EOT;
</pre></body></html>
EOT
}
