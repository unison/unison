#!/usr/bin/env perl
#######################################################
$ID = $Id$;
#represents a 3d structural entity
###########################################################

package Unison::Structure;

use strict;
use Carp;

use vars qw( $VERSION );


sub new {
    my ($class,$pdb_id,$name) = @_;
    my $self = {};
    bless $self,$class;
    if(!defined($pdb_id)) {
        warn "Structure needs an id to initialize\n";
        return undef;
    }
    else {$self->{'id'} = $pdb_id;}
    $self->{'pdb_id'} = substr($self->{'id'},0,4);
    $self->{'chain'} = substr($self->{'id'},4,1);

  # store other characteristics of this structral template
    $self->{'name'} = $name if(defined($name));
    $self->{'aaa2a'} = undef;
    $self->{'residues'} = undef;
    $self->{'atom_seq'} = undef;
    $self->{'num_residues'} = undef;

    my ($pdb_fh, $pdb_fn) = File::Temp::tempfile(UNLINK => 0, DIR => '/tmp', SUFFIX=>'.pdb');

    my $pdbDir = (defined($ENV{PDB_PATH}) ? $ENV{PDB_PATH} : '/gne/compbio/share/pdb/all.ent');
    my ($pdb_id) = $self->{'pdb_id'};
    
    copy_file("$pdbDir/pdb$pdb_id.ent",$pdb_fn);
    
    my $stream = Bio::Structure::IO->new(-fh => $pdb_fh, 
    				      -format => 'PDB');
    my $structure = $stream->next_structure();
 
    if(defined($structure)) {
	$self->{'bp_structure'}=$structure;
    }
    else {
	warn "Structure.pm couldn't create bio Bio::Structure object\n";
	return undef;
    }
    
    $self->_get_atom_seq();
    
    return( $self );
}

sub _get_atom_seq {

  my ($self) = @_;
  my ($seq,$residues);

  my $structure = $self->{'bp_structure'};

  foreach my $model ( $structure->get_models( $structure ) ) {
      foreach my $chain ( $structure->get_chains( $model ) ) {
	  next unless (($chain->id() eq $self->{'chain'}) or $self->{'chain'} eq '');
	  @$residues = $structure->get_residues( $chain );
	  foreach my $residue(@$residues) {
	      my ($resname,$resseq) = split '-', $residue->id();
	      $seq .=  $self->_aaa_to_a_code( $resname);
	  }
      }
  }

  $self->{'atom_seq'} = $seq;
  $self->{'residues'} = $residues;
  $self->{'num_residues'} = $#{$residues}+1;
}

sub get_res_pos {

    my ($self,$pos) = @_;
    if($pos < 0) {
	warn "residue $pos requested from structure $self->{'id'}\n";
	return undef;
    }
    my $res = $self->{'residues'}->[$pos-1];
    if(!defined($res)) {
      warn "Structure : Couldn't get residue id for position $pos in $self->{'id'}\n";
      return undef;
    }
    my @residue = split(/-/, $res->id());
    return ($self->_aaa_to_a_code($residue[0])."-$residue[1]-$self->{'chain'}");
}

sub _aaa_to_a_code {

    my ($self,$aaa) = @_;

    if ( ! defined $self->{'aaa2a'} ) {
	my $alpha = new Bio::Symbol::ProteinAlphabet();
	foreach my $symbol ( $alpha->symbols ) {
	    $self->{'aaa2a'}->{uc($symbol->name())} = $symbol->token() ;
	}
    }
    return( $self->{'aaa2a'}->{$aaa} );
}

sub copy_file {
  my ($file1,$file2) = @_;
  system("cp $file1 $file2");
  return 1;
}


'some true value';

