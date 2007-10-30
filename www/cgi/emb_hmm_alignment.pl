#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use CGI( -debug );
use CGI::Carp qw(fatalsToBrowser);

use Unison::WWW;
use Unison::WWW::EmbPage;
use Unison::WWW::Table;
use Unison::Exceptions;

use Bio::SeqIO;
use Bio::SearchIO;

use IO::Pipe;

my $pfamURL = 'http://pfam.janelia.org/cgi-bin/getdesc?acc=%s';

my $p = new Unison::WWW::EmbPage;
my $u = $p->{unison};
my $v = $p->Vars();

$p->ensure_required_params(qw(pseq_id params_id pmodelset_id profiles));

try {
  my $html = _run_sequence($p);
  print $p->render("Unison:$v->{pseq_id} aligned to $v->{profiles}", 
		   $html
		  );
} catch Unison::Exception with {
  $p->die($_[0]);
};


sub _run_sequence() {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();

  my ($hmmfh, $hmmfn) = $p->tempfile(SUFFIX=>'.hmm');
  my ($seqfh, $seqfn) = $p->tempfile(SUFFIX=>'.fasta');
  my ($htmlfh, $htmlfn) = $p->tempfile(SUFFIX=>'.html');

  my $modelfile = _get_model_file();

  my $seq = $u->get_sequence_by_pseq_id( $v->{pseq_id} );
  if (not defined $seq)
	{ $p->die("couldn't fetch sequence for pseq_id=$v->{pseq_id}"); }
  my $so = new Bio::SeqIO( -format => 'fasta',
						   -file => ">$seqfn" )
	|| $p->die("! couldn't open $seqfn for writing\n");
  $so->write_seq( new Bio::PrimarySeq( -seq => $seq,
									   -id => "Unison:$v->{pseq_id}" ) );
  $so->close();


  my @profiles = split(/[\0,]/,$v->{profiles});
  foreach (@profiles) {
	my $cmd = "hmmfetch $modelfile $_ >> $hmmfn";
	system( $cmd )
	  && $p->die("$cmd: $!\n");
  }


  my $clo = $u->run_commandline_by_params_id($v->{params_id});
  my @cl = (split(' ',$clo), $hmmfn, $seqfn);
  my $hmmerpipe = new IO::Pipe;
  $hmmerpipe->reader( @cl )
	|| $p->die("couldn't do @cl\n");
  my $html = "<pre>\ncommand line: $clo\n\n\n";
  my $print = 0;
  while( my $line = <$hmmerpipe> ) {
	if ($line =~ m/^Alignments of top-scoring domains/) {
	  $print++;
	  next;
	}
	next unless $print;
	$html .= $line;
  }
  $html .= '</pre>';
  close($hmmerpipe);

  return $html;
}



sub _get_model_file {
  my $data_url;
  my $sql = "select data_url from pmodelset where pmodelset_id=".$v->{pmodelset_id};
  try {
    $data_url = $u->selectrow_array($sql);
  };
  $p->die("Could not get data_url for pmodelset_id = ".$v->{pmodelset_id}) if(!$data_url);

  my $abs_url = $p->url(-absolute=>1);
  $abs_url =~ s/.*(cgi\/.*)/$1/;

  #this is the relative path for unison runtime dir
  my $return_path='../' x (scalar split /\//, $abs_url);
  return $return_path.$data_url;
}
