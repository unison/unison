#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../../perl5";

use CGI( -debug );
use CGI::Carp qw(fatalsToBrowser);

use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

use Bio::SeqIO;
use Bio::SearchIO;
use Bio::SearchIO::Writer::HTMLResultWriter;

use IO::Pipe;

my $pfamURL = 'http://pfam.wustl.edu/cgi-bin/getdesc?acc=%.7s';

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

$p->ensure_required_params(qw(pseq_id params_id profiles));


my $modelfile = '/gne/compbio/share/pfam-14.0/Pfam_fs.hmm';
my ($hmmfh, $hmmfn) = $p->tempfile(SUFFIX=>'.hmm');
my ($seqfh, $seqfn) = $p->tempfile(SUFFIX=>'.fasta');
my ($htmlfh, $htmlfn) = $p->tempfile(SUFFIX=>'.html');


my $seq = $u->get_sequence_by_pseq_id( $v->{pseq_id} );
if (not defined $seq)
  { $p->die("couldn't fetch sequence for pseq_id=$v->{pseq_id}"); }

my $so = new Bio::SeqIO( -format => 'fasta',
			 -file => ">$seqfn" )
  || die("! couldn't open $seqfn for writing\n");
$so->write_seq( new Bio::PrimarySeq( -seq => $seq,
				     -id => "Unison:$v->{pseq_id}" ) );
$so->close();

my @profiles = split(/[\0,]/,$v->{profiles});

foreach (@profiles) {
  my $cmd = "hmmfetch $modelfile $_ >> $hmmfn";
  system( $cmd )
	&& die("$cmd: $!\n");
}
my $clo = $u->run_commandline_by_params_id($v->{params_id});
my @cl = (split(' ',$clo), '--acc', $hmmfn, $seqfn);

my $hmmerpipe = new IO::Pipe;
$hmmerpipe->reader( @cl )
  || die("couldn't do @cl\n");

my $in = new Bio::SearchIO(-format => 'hmmer',-fh => $hmmerpipe);

my $writer = new Bio::SearchIO::Writer::HTMLResultWriter();
$writer->title(\&dummy_sub);
$writer->introduction(\&dummy_sub);
$writer->remote_database_url('N',$pfamURL);

my $out = new Bio::SearchIO(-writer => $writer, -fh => $htmlfh);
$out->write_result($in->next_result);

# get rid of statistics info from html
seek($htmlfh,0,0);
my $html;
while(<$htmlfh>) {
  next if /Identities/;
  last if /Search Parameters/;
  my $line = $_;
  if(/Expect/) {#could be done better!
    $line =~ s/\(/\, E \= /;
    $line =~ s/\), Expect =//;
  }
  $html .= $line;
}


print $p->render("HMMER alignments of selected profiles with Unison:$v->{pseq_id}", 
		 $p->group('PFAM Hits ',
			'<b>',$html,'</b>')
		);

$hmmerpipe->close();
close($htmlfh);

sub dummy_sub { return "";}

