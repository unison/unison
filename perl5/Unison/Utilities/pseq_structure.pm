###########################################################
#!/usr/bin/env perl
# purpose : a core module for linking a sequence to its availabe structures
# and location of its features(hmm's, snp's .. etc) to structural locations
###########################################################

=head1 NAME

Unison::pseq_structure -- sequence-to-structure-related functions for Unison

$ID = q$Id: pseq_structure.pm,v 1.6 2005/06/17 17:14:52 mukhyala Exp $;

=head1 SYNOPSIS

 use Unison;
 use Unison::pseq_structure;
 my $ps = new Unison::pseq_structure(...);

=head1 DESCRIPTION

=cut


package Unison::Utilities::pseq_structure;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = ();

use IO::Pipe;

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
    $self->{'num_structures'} = 0;
    $self->{'num_templates'} = 0;
    $self->{'loaded_structure'} = undef;
    $self->{'unison'} = undef;
    $self->{'features'} = {};
    $self->{'templates'} = {};
    $self->{'structure_ids'} = ();
    $self->{'template_ids'} = ();
    $self->{'seq_str_map'} = {};
    $self->{'length'} = undef;

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

sub jmol {
    my ($self,$j) = @_;

    if ( defined $j ) {
	$self->{'jmol'} = $j;
    } else {
	return $self->{'jmol'} || undef;
    }
}

sub find_structures {

    my $self = shift;

    my $structures_sql = "select pdbc, descr from v_alias_pdbcs where pseq_id=$self->{'pseq_id'}";
    my $structures_ar = $self->{'unison'}->selectall_arrayref($structures_sql);

    return undef unless defined($structures_ar);
    $self->initialize_structures($structures_ar);
    return $structures_ar;
}

sub initialize_structures {

    my ($self,$ar) = @_;
    foreach my $r(@$ar) {

      $self->_get_seq_str_map($r->[0]);
	push @{$self->{'structure_ids'}}, $r->[0];
	$self->{'num_structures'}++;
    }
}

sub find_snps {

    my $self = shift;

    my $snp_sql = "select s.original_aa,s.variant_aa,s.start_pos,s.descr,s.var_id from v_pseq_sp_var s where s.pseq_id=".$self->{'pseq_id'};

    my $snp_data = $self->{'unison'}->selectall_arrayref($snp_sql);

    $self->initialize_snps($snp_data);
}

#not used, but will use after we move to a permanent mim schema
sub get_mims {

     my $self = shift;
     my $mim_sql = "select m.mim_number,m.title,m.gene_symbols,m.disorders,m.mouse_correlate,m.chr_map from mukhyala.mim m join mukhyala.pseq_mim p on p.mim_number=m.mim_number and pseq_id=".$self->{'pseq_id'};
     return $self->{'unison'}->selectall_arrayref($mim_sql);
}

sub initialize_snps {

    my ($self,$ar) = @_;

    foreach my $r(@$ar) {
	my $snp = ({'pseq_id' => $self->{'pseq_id'}, 'wt_aa' => $r->[0], 'var_aa' => $r->[1], 'start' => $r->[2], 'end' => $r->[5], 'name' => $r->[3], 'ref' => $r->[4]});
	push @{$self->{'features'}{'snps'}}, $snp;
    }
}

#Don't call this any more
sub set_templates {
    my ($self,$ar) = @_;
    foreach my $r(@$ar) {
	$self->{'templates'}{$r->[2].$r->[3]} = undef;
    }
}

sub find_templates {

    my $self = shift;

    my $templates_sql = "select B.t_pseq_id,B.pdbc, B.descr,B.q_start,B.q_stop,B.t_start,B.t_stop,B.ident,B.sim,B.gaps,B.eval,B.pct_ident,B.len,B.pct_coverage from v_papseq_pdbcs B where B.q_pseq_id = $self->{'pseq_id'} and B.pct_ident>50 order by B.pct_coverage desc, B.pct_ident desc";

    my $templates_ar = $self->{'unison'}->selectall_arrayref($templates_sql);
    $self->initialize_templates($templates_ar);

    return $templates_ar;
}
sub initialize_templates {

    my ($self,$ar) = @_;
    foreach my $r(@$ar) {
      $self->_get_seq_str_map($r->[1]);
      push @{$self->{'template_ids'}}, $r->[1];
      $self->{'num_templates'}++;
      $self->{'templates'}{$r->[1]}{qstart}=$r->[3];
      $self->{'templates'}{$r->[1]}{qstop}=$r->[4];
      $self->{'templates'}{$r->[1]}{tstart}=$r->[5];
      $self->{'templates'}{$r->[1]}{descr}=$r->[2];
    }
}

sub load_first_structure {

    my $self = shift;
    $self->{'loaded_structure'} = ($self->{'num_structures'} == 0 ? ${$self->{template_ids}}[0] : ${$self->{structure_ids}}[0]);
}

sub pseq_length {

  my $self= shift;
  if(!defined($self->{'length'}) and defined($self->{'unison'})) {
    my $qseq = $self->{'unison'}->get_sequence_by_pseq_id( $self->{'pseq_id'} );
    $self->{'length'} = length($qseq);
  }
  return $self->{'length'};
}

sub _get_seq_str_map {

  my ($self,$pdbCode) = @_;

  my $map_sql = "select seq_pos,res_id, seq_res,atom_res from pdb.residue where pdbc=\'$pdbCode\'";

  my $map_ar = $self->{'unison'}->selectall_arrayref($map_sql);

  return undef unless defined($map_ar);
  foreach my $r(@$map_ar) {
    $self->{'seq_str_map'}{$pdbCode}{$r->[0]}{'res_id'} = $r->[1];
    $self->{'seq_str_map'}{$pdbCode}{$r->[0]}{'seq_res'} = $r->[3];
    $self->{'seq_str_map'}{$pdbCode}{$r->[0]}{'atom_res'} = $r->[4];
    #print "$pdbCode\t",$r->[0],"\t",$r->[1],"\t",$r->[2],"\n";
  }
}

sub get_hmm_range {

    my ($self,$hmm) = @_;
    my $sql = "select a.start,a.stop from pahmm a join pmodel m on a.pmodel_id=m.pmodel_id where pseq_id=$self->{'pseq_id'} and m.descr ilike \'\%$hmm\%\'";
    my $ar = $self->{'unison'}->selectall_arrayref($sql);
    return $ar->[0];
}


####################################################################################
# related to jmol javascript
sub set_js_vars {
  my ($self) = @_;

  my $retval;
  my $stringio = IO::String->new($retval);

  $stringio->print("<!-- sequence-structure mapping -->\n");
  $stringio->print("<form><script LANGUAGE=\"javascript\">\nvar seq_str = new Object; var pdbid;\n");

  foreach my $pdbid(@{$self->{'structure_ids'}}) {
    $stringio->print("pdbid = \'$pdbid\';seq_str[pdbid] = new Object;");
    for(my $i=1; $i<=$self->pseq_length; $i++) {
      my $pdb_res = $self->{'seq_str_map'}{$pdbid}{$i};
      my $res = $pdb_res->{'res_id'};
      $stringio->print("seq_str[pdbid][$i] = \'$res\';") if(defined($res));
    }
	$stringio->print("\n");
  }

  foreach my $pdbid(@{$self->{'template_ids'}}) {
    my $j  = 0;
    $stringio->print("pdbid = \'$pdbid\';seq_str[pdbid] = new Object;");
    for( my $i=$self->{'templates'}{$pdbid}{'qstart'};
		 $i<=$self->{'templates'}{$pdbid}{'qstop'};
		 $i++) {
      my $template_pos = $self->{'templates'}{$pdbid}{'tstart'} + $j++;
      next if (!defined($self->{'seq_str_map'}{$pdbid}{$template_pos}));
      my $pdb_res = $self->{'seq_str_map'}{$pdbid}{$template_pos};
      my $res = $pdb_res->{'res_id'};
      $stringio->print("seq_str[pdbid][$i] = \'$res\';") if(defined($res));
    }
	$stringio->print("\n");
  }
  $stringio->print("pdbid=\'$self->{loaded_structure}\';</script></form>\n");
  return $retval;
}

sub region_script {

  my ($self,$start,$end,$label,$colour) = @_;
  my $jmol = $self->{'jmol'};
  return "javascript:".$jmol->selectRegion($start,$end,$label,$colour);
}

sub pos_script {
  my ($self,$pos,$label,$colour) = @_;
  my $jmol = $self->{'jmol'};
  return "javascript:".$jmol->selectPosition($pos,$label,$colour);
}

sub change_structure {
  my ($self,$name) = @_;
  my ($pdb_id,$chain) = (substr($name,0,4),substr($name,4,1));
  my $jmol = $self->{'jmol'};
  return "javascript:".$jmol->changeStructureLoad($jmol->load("pdb$pdb_id.ent",$chain),$name);
}

1;


