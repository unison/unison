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
use Bio::SearchIO::Writer::HTMLResultWriter;

use IO::Pipe;

my $pfamURL = 'http://pfam.wustl.edu/cgi-bin/getdesc?acc=%s';

my $p = new Unison::WWW::EmbPage;
my $u = $p->{unison};
my $v = $p->Vars();

$p->ensure_required_params(qw(pseq_id params_id profiles));


try {
  my $html = _run_sequence($p);
  print $p->render("HMMER alignments of selected profiles with Unison:$v->{pseq_id}", 
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
  my @cl = (split(' ',$clo), '--acc', $hmmfn, $seqfn);


  my $hmmerpipe = new IO::Pipe;
  $hmmerpipe->reader( @cl )
	|| $p->die("couldn't do @cl\n");
  my $in = new Bio::SearchIO(-format => 'hmmer',-fh => $hmmerpipe);


  my $writer = new Bio::SearchIO::Writer::HTMLResultWriter();
  $writer->title( sub {''} );
  $writer->introduction( sub {''} );
  $writer->remote_database_url('N',$pfamURL);

  my $out = new Bio::SearchIO(-writer => $writer, -fh => $htmlfh);
  $out->write_result($in->next_result);

  $hmmerpipe->close();


  # get rid of statistics info from html
  seek($htmlfh,0,0);
  my $html = '';
  while( my $line = <$htmlfh> ) {
	last if $line =~ /Search Parameters/;
	$html .= $line;
  }
  close($htmlfh);

  return $html;
}



sub _get_model_file {
  my $data_url;
  my $sql = "select o.data_url from porigin o,run_history h where o.porigin_id=h.porigin_id and h.params_id=".$v->{params_id}." and h.pseq_id=".$v->{pseq_id};
  try {
    $data_url = $u->selectrow_array($sql);
  };
  $p->die("Could not get data_url for params_id = ".$v->{params_id}." and pseq_id = ".$v->{pseq_id}) if(!$data_url);
  return $data_url;
}
