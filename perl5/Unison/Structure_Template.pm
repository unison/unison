#!/usr/bin/env perl
$ID = $Id$;
#represents a single structure/template for a given sequence
###########################################################

package Unison::Structure_Template;

use strict;
use Carp;

use Bio::Structure::IO;
use Bio::Symbol::ProteinAlphabet;
use Bio::Tools::Run::StandAloneBlast;
use Bio::Tools::BPbl2seq;

use vars qw( $VERSION );
###$VERSION = sprintf( "%d.%02d", q $ =~ /(\d+)\.(\d+)/ );


sub new {
    my ($class,$pseq_id,$master_pseq_id) = @_;
    my $self = {};
    bless $self,$class;
    if(!defined($pseq_id)) {
	warn "Structure_Template needs a pseq_id to initialize\n";
	return undef;
    }
    else {$self->{'pseq_id'} = $pseq_id;}

  # store other characteristics of this structral template
    $self->{'master_pseq_id'} = $master_pseq_id if(defined($master_pseq_id));
    $self->{'master_seq_length'} = undef;
    $self->{'master_seq'} = undef;
    $self->{'structure'} = undef;
    $self->{'features'} = {};
    $self->{'seq_aln'} = {};

    return( $self );
}

sub structure {
    my ($self,$structure) = @_;

    if ( defined $structure ) {  
	$self->{'structure'} = $structure;
    } else {              
	return $self->{'structure'} || undef;
    }
}

sub aln_seq_structure {

    my ($self,$u) = @_;

    my ($seq) = $self->{'structure'}->{'atom_seq'};

    if(!defined($seq)) {
	warn "Structure_Template no sequence from structure";
	return;
    }

    my $qseq = $u->get_sequence_by_pseq_id( $self->{'master_pseq_id'} );

    $self->{'master_seq_length'} = length($qseq);
    $self->{'master_seq'} = $qseq;

    my $qseq_obj = Bio::Seq->new( -display_id => $$,
				  -seq => $qseq);
    my $sseq_obj = Bio::Seq->new( -display_id => $$.$$,
				  -seq => $seq);

    my ($bl2out_fh, $bl2out_fn) = File::Temp::tempfile(UNLINK => 0,
						       DIR => '/tmp',
						       SUFFIX=>".$$.bl2out");

    my $seq1 = Bio::Seq->new( -display_id => 'seq1',-seq => $qseq);
    my $seq2 = Bio::Seq->new( -display_id => 'seq2',-seq => $seq);

    my $factory = Bio::Tools::Run::StandAloneBlast->new('outfile' => $bl2out_fn, 'program' => 'blastp');
    my $bl2seq_report = $factory->bl2seq($seq1, $seq2);

    my $report = Bio::Tools::BPbl2seq->new(-file => $bl2out_fn, -report_type => 'blastp');
    my $hsp = $report->next_feature();

    my @q_aas = split(//,$hsp->querySeq);
    my @h_aas = split(//,$hsp->sbjctSeq);
    my ($qgaps,$hgaps) = (0,0);
    #print $self->{'structure'}->{'id'},"\n",$hsp->querySeq,"\n",$hsp->homologySeq,"\n",$hsp->sbjctSeq,"\n",$qseq,"\n",$seq,"\n";
    foreach my $i(0..$#q_aas) {
	if($q_aas[$i] eq '-') {$qgaps++;}
	elsif($h_aas[$i] eq '-') {$hgaps++;}

	else {$self->{'seq_aln'}{$i+$hsp->query->start-$qgaps} = $i + $hsp->hit->start - $hgaps;}

	#print "i=$i\tseq_pos=",eval($i+$hsp->query->start-$qgaps),"\tqaa=",$q_aas[$i],"\thaa=",$h_aas[$i],"\tqgaps=$qgaps\thgaps=$hgaps\tq_st=",$hsp->query->start,"\th_st=",$hsp->hit->start,"\th_res=",$self->{'seq_aln'}{$i + $hsp->query->start - $hgaps},"\n";
    }


}

sub set_js_vars {

  my ($self) = @_;
  my $retval;
  my $stringio = IO::String->new($retval);
  my ($length) = $self->{'structure'}->{'num_residues'};
  my ($pdb) = $self->{'structure'}->{'id'};
  $stringio->print("<form><script LANGUAGE=\"javascript\">pdbid = \'$pdb\';seq_str[pdbid] = new Object;");
  my $j = 1;
  foreach my $i(sort {$a<=>$b} keys %{$self->{'seq_aln'}}) {
    my @residue = split(/-/,$self->{structure}->get_res_pos($j++));
    $stringio->print("seq_str[pdbid][$i] = \'$residue[1]\';\n");
  }
  $stringio->print("</script></form>");
  return( $retval );
}


sub get_res_pos {

  my ($self,$seq_pos) = @_;
  if($seq_pos < 0) {
      warn "Structure_Template: residue from sequence position $seq_pos requested\n";
      return undef;
  }
  my $structure_pos = $self->{'seq_aln'}{$seq_pos};
  if($structure_pos < 0) {
      warn "Structure_Template: reqesting residue $structure_pos : possible sequence structure alignment issues\n";
      return undef;
  }
  return $self->{structure}->get_res_pos($structure_pos);
}


'some true value';
