=head1 NAME

Unison::pseq_structure -- sequence-to-structure-related functions for Unison

$ID = q$Id: pseq_structure.pm,v 1.9 2005/08/08 21:41:12 rkh Exp $;

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

use Unison::Utilities::pfssp_psipred;


sub new {
  my ($class,$pseq_id) = @_;
  my $self = {};
  bless $self,$class;
  if (!defined($pseq_id)) {
	warn "pseq_structure needs a pseq_id to initialize\n";
	return undef;
  } else {
	$self->{'pseq_id'} = $pseq_id;
  }

  # store other characteristics of this structral template
  $self->{'num_structures'} = 0;
  $self->{'num_templates'} = 0;
  $self->{'loaded_structure'} = undef;
  $self->{'unison'} = undef;
  $self->{'features'} = {};
  $self->{'structure_template'} = {};
  $self->{'structure_template_ids'} = ();
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


sub find_structure_templates {
  my $self = shift;
  my $st_sql = "select distinct on (pct_coverage,t_pseq_id,substr(template,1,4)) B.q_pseq_id,B.template, B.q_start,B.q_stop,B.t_start,B.t_stop,B.gaps,B.eval,B.score,B.pct_ident,B.len,B.pct_coverage,method, B.descr from v_pseq_template B where B.q_pseq_id = $self->{'pseq_id'} order by pct_coverage desc, t_pseq_id, substr(template,1,4) limit 20";
  my $structure_templates_ar = $self->{'unison'}->selectall_arrayref($st_sql);
  return undef unless defined $structure_templates_ar;
  $self->initialize_structure_templates($structure_templates_ar);
  return $structure_templates_ar;
}


sub initialize_structure_templates {
  my ($self,$ar) = @_;
  foreach my $r (@$ar) {
	$self->_get_seq_str_map($r->[1]);
	push @{$self->{'structure_template_ids'}}, $r->[1];
	$self->{'num_structure_templates'}++;
	$self->{'structure_templates'}{$r->[1]}{descr}=$r->[13];
	$self->{'structure_templates'}{$r->[1]}{qstart}=$r->[2];
	$self->{'structure_templates'}{$r->[1]}{qstop}=$r->[3];
	$self->{'structure_templates'}{$r->[1]}{tstart}=$r->[4];
  }
}


sub find_snps {
  my $self = shift;
  my $snp_sql = "select s.original_aa,s.variant_aa,s.start_pos,s.descr,s.var_id from v_pseq_sp_var s where s.pseq_id=".$self->{'pseq_id'};
  my $snp_data = $self->{'unison'}->selectall_arrayref($snp_sql);
  $self->initialize_snps($snp_data);
}


sub initialize_snps {
  my ($self,$ar) = @_;
  foreach my $r (@$ar) {
	my $snp = ({'pseq_id' => $self->{'pseq_id'}, 'wt_aa' => $r->[0], 'var_aa' => $r->[1], 'start' => $r->[2], 'end' => $r->[5], 'name' => $r->[3], 'ref' => $r->[4]});
	push @{$self->{'features'}{'snps'}}, $snp;
  }
}


sub load_first_structure {
  my $self = shift;
  $self->{'loaded_structure'} = ${$self->{'structure_template_ids'}}[0];
}


sub _get_seq_str_map {
  my ($self,$pdbCode) = @_;

  my $pdbc=lc(substr($pdbCode,0,4)).uc(substr($pdbCode,4,1));

  my $map_sql = "select seq_pos,res_id, seq_res,atom_res from pdb.residue where pdbc=\'$pdbc\'";

  my $map_ar = $self->{'unison'}->selectall_arrayref($map_sql);

  return undef unless defined($map_ar);
  foreach my $r (@$map_ar) {
    $self->{'seq_str_map'}{$pdbCode}{$r->[0]}{'res_id'} = $r->[1];
    $self->{'seq_str_map'}{$pdbCode}{$r->[0]}{'seq_res'} = $r->[3];
    $self->{'seq_str_map'}{$pdbCode}{$r->[0]}{'atom_res'} = $r->[4];
  }
}

#this is used in parsing user features
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

  $stringio->print("<form><script LANGUAGE=\"javascript\">var seq_str = new Object; var pdbid;");

  foreach my $pdbid (@{$self->{'structure_template_ids'}}) {

    my $j  = 0;
    $stringio->print("pdbid = \'$pdbid\';seq_str[pdbid] = new Object;");

    foreach my $i ($self->{'structure_templates'}{$pdbid}{'qstart'}..$self->{'structure_templates'}{$pdbid}{'qstop'}) {
      my $template_pos = $self->{'structure_templates'}{$pdbid}{'tstart'} + $j++;
      next if (!defined($self->{'seq_str_map'}{$pdbid}{$template_pos}));
      my $pdb_res = $self->{'seq_str_map'}{$pdbid}{$template_pos};
      my $res = $pdb_res->{'res_id'};

      $stringio->print("seq_str[pdbid][$i] = \'$res\';\n") if(defined($res));
    }
  }
  $stringio->print("pdbid=\'".$self->{loaded_structure}."\';</script></form>");
  return $retval;
}

sub region_script {
  my ($self,$start,$end,$label,$color) = @_;
  my $jmol = $self->{'jmol'};
  return "javascript:".$jmol->selectRegion($start,$end,$label,$color);
}

sub pos_script {
  my ($self,$pos,$label,$color) = @_;
  my $jmol = $self->{'jmol'};
  return "javascript:".$jmol->selectPosition($pos,$label,$color);
}

sub change_structure {
  my ($self,$name) = @_;
  my ($pdb_id,$chain) = (substr($name,0,4),substr($name,4,1));
  my $jmol = $self->{'jmol'};
  return "javascript:".$jmol->changeStructureLoad($jmol->load("pdb$pdb_id.ent",$chain),$name);
}

1;

