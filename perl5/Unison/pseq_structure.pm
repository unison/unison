###########################################################
#!/usr/bin/env perl
# purpose : a core module for linking a sequence to its availabe structures
# and location of its features(hmm's, snp's .. etc) to structural locations
###########################################################
=head1 NAME

Unison::pseq_structure -- sequence-structure-related functions for Unison

$ID = q$Id$;

=head1 SYNOPSIS

 use Unison;
 use Unison::pseq_structure;
 my $ps = new Unison::pseq_structure(...);

=head1 DESCRIPTION

=cut


package Unison::pseq_structure;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = ();

use Bio::Structure::IO;
use Bio::Symbol::ProteinAlphabet;
use Bio::Tools::Run::StandAloneBlast;
use Bio::Tools::BPbl2seq;

use IO::Pipe;
use Unison::Exceptions;
use Unison::Structure;
use Unison::Structure_Template;
use Unison::pseq_snp;

sub new {
    my ($class,$pseq_id) = @_;
    my $self = {};
    bless $self,$class;
    if(!defined($pseq_id)) {
        warn "pseq_structure needs a pseq_id to initialize\n";
        return undef;
    }
    else {$self->{'pseq_id'} = $pseq_id;}

    # store other characteristics of this structral template
    $self->{'aaa2a'} = undef;
    $self->{'num_structures'} = 0;
    $self->{'num_templates'} = 0;
    $self->{'structures_templates'} = {};
    $self->{'loaded_structure'} = undef;
    $self->{'unison'} = undef;
    return( $self );
}

sub unison {
    my ($self,$u) = @_;

    if ( defined $u ) {
	$self->{'unison'} = $u;
    } else {
	return $self->{'unison'} || undef;
    }
}

sub find_structures {

    my $self = shift;

    my $structures_sql = "select alias, descr from palias where pseq_id=$self->{'pseq_id'} and porigin_id=11";
    my $structures_ar = $self->{'unison'}->selectall_arrayref($structures_sql);

    return undef unless defined($structures_ar);
    $self->initialize_structures($structures_ar);
    return $structures_ar;
}

sub initialize_structures {

    my ($self,$ar) = @_;
    foreach my $r(@$ar) {
	my $s = new Unison::Structure($r->[0],$r->[1]);
	my $st = new Unison::Structure_Template($self->{pseq_id},$self->{pseq_id});
	next unless (defined($st) and defined($s));
	$st->structure($s);
	$st->aln_seq_structure($self->{'unison'});
	push @{$self->{'structure_ids'}}, $r->[0];
	$self->{'structures_templates'}{$r->[0]} = $st;
	$self->{'num_structures'}++;
    }
}

sub find_snps {

    my $self = shift;

    my $jmb_sql = "select f.original_aa,f.variant_aa,f.pdb_id,f.pdb_chain,f.pdb_pos,f.acc_pos,m.title,m.mim_number from mukhyala.pseq_mim p join mukhyala.fasp_omim f on f.swissprot_id=p.alias join mukhyala.mim m on m.mim_number = p.mim_number where p.pseq_id=".$self->{'pseq_id'};

    my $jmb_data = $self->{'unison'}->selectall_arrayref($jmb_sql);

    $self->initialize_snps($jmb_data);
    $self->set_templates($jmb_data);
}

sub initialize_snps {

    my ($self,$ar) = @_;
    
    foreach my $r(@$ar) {
	my $snp = new Unison::pseq_snp({'pseq_id' => $self->{'pseq_id'}, 'wt_aa' => $r->[0], 'var_aa' => $r->[1], 'start' => $r->[5], 'end' => $r->[5], 'name' => $r->[6], 'ref' => $r->[7]});
	push @{$self->{'features'}{'snps'}}, $snp;
    }
}

sub set_templates {
    my ($self,$ar) = @_;
    foreach my $r(@$ar) {
	$self->{'templates'}{$r->[2].$r->[3]} = undef;
    }
}
sub find_templates {

    my $self = shift;

    my @jmb_pdbs = map {"'$_'"} keys %{$self->{'templates'}};

    my $pdbs = join ',',@jmb_pdbs;

    my $templates_sql = "select B.target,p.alias, p.descr,B.qstart,B.qstop,B.tstart,B.tstop,B.ident,B.sim,gaps,B.eval,B.pct_ident,B.len,B.pct_coverage from v_papseq B join palias p on B.target=p.pseq_id where p.porigin_id=11 and B.query = $self->{'pseq_id'} and B.gaps=0 and p.alias in ($pdbs) order by B.pct_ident desc, pct_hsp_coverage desc";

    my $templates_ar = $self->{'unison'}->selectall_arrayref($templates_sql);
    $self->initialize_templates($templates_ar);
    return $templates_ar;
}
sub initialize_templates {

    my ($self,$ar) = @_;
    foreach my $r(@$ar) {
	my $s = new Unison::Structure($r->[1],$r->[2]);
	my $st = new Unison::Structure_Template($r->[0],$self->{pseq_id});
	next unless (defined($st) and defined($s));
	$st->structure($s);	
	$st->aln_seq_structure($self->{'unison'});
	push @{$self->{'template_ids'}}, $r->[1];
	$self->{'structures_templates'}{$r->[1]} = $st;
	$self->{'num_templates'}++;
    }
}

sub load_first_structure {

    my $self = shift;    
    $self->{'loaded_structure'} = ($self->{'num_structures'} == 0 ? ${$self->{template_ids}}[0] : ${$self->{structure_ids}}[0]);
}

sub get_res_pos {

  my ($self,$seq_pos) = @_;

  if($seq_pos < 1) {
      warn "pseq_structure: residue $seq_pos requested\n";
      return undef;
  }
  my $current_structure = $self->{'loaded_structure'};
  if(defined($current_structure)) {
      return $self->{structures_templates}{$current_structure}->get_res_pos($seq_pos);
  }
  else {
      warn "Couldn't get the currently loaded structure\n";
      return undef;
  }
}

####################################################################################
# related to jmol javascript
sub set_js_vars {

  my ($self) = @_;

  my $retval;
  my $stringio = IO::String->new($retval);
  foreach my $pdb_id(keys %{$self->{'structures_templates'}}) {
    $stringio->print($self->{'structures_templates'}{$pdb_id}->set_js_vars());
  }
  return $retval;
}

sub snp_link {

    my ($self,$seq_pos) = @_;

    my @residue = split(/-/,$self->get_res_pos($seq_pos));
    #$p->die("residue from structure $residue[0]($residue[1]) doesn't match snp amino acid $r->[0]($r->[5])\n") if($r->[0] ne $residue[0]);
    my $jmol = new Unison::Jmol();
    return $jmol->script($jmol->snp_view($residue[1],$residue[2],$residue[0]));
}

sub region_script {

  my ($self,$start,$end,$label) = @_;
  my $jmol = new Unison::Jmol();
  return $jmol->selectRegion($start,$end,$label);
}

sub pos_script {

  my ($self,$pos,$label) = @_;
  my $jmol = new Unison::Jmol();
  return $jmol->selectPosition($pos,$label);
}

'some true value';

