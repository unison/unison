#BioPerl module for Bio::Tools::Blat
#
# Cared for by  Balamurugan Kumarasamy
#
# You may distribute this module under the same terms as perl itself
# POD documentation - main docs before the code
#

=head1 NAME

Bio::Tools::ProteinToGenomeBlat  

=head1 SYNOPSIS

  use Bio::Tools::ProteinToGenomeBlat;
  my $blat_parser = new Bio::Tools::ProteinToGenomeBlat(-fh =>$filehandle );
  while( my $blat_feat = $blat_parser->next_result ) {
        push @bllat_feat, $blat_feat;
  }

=head1 DESCRIPTION

 Parser for Blat  program

=head1 FEEDBACK

=head2 Mailing Lists

 User feedback is an integral part of the evolution of this and other
 Bioperl modules. Send your comments and suggestions preferably to
 the Bioperl mailing list.  Your participation is much appreciated.

 bioperl-l@bioperl.org              - General discussion
 http://bioperl.org/MailList.shtml  - About the mailing lists

=head2 Reporting Bugs

 Report bugs to the Bioperl bug tracking system to help us keep track
 of the bugs and their resolution. Bug reports can be submitted via
 email or the web:

 bioperl-bugs@bioperl.org
 http://bugzilla.bioperl.org/

=head1 AUTHOR - Balamurugan Kumarasamy

 Email: bala@tll.org.sg

=head1 APPENDIX

 The rest of the documentation details each of the object methods.
 Internal methods are usually preceded with a _


=cut

package Bio::Tools::ProteinToGenomeBlat;
use vars qw(@ISA);
use strict;
use Bio::SeqFeature::Generic;
use Bio::Root::Root;
use Bio::SeqFeature::FeaturePair;
use Bio::Root::IO;
use Bio::SeqFeature::Generic;
@ISA = qw(Bio::Root::Root Bio::Root::IO );



=head2 new

 Title   : new
 Usage   : my $obj = new Bio::Tools::ProteinToGenomeBlat(-fh=>$filehandle);
 Function: Builds a new Bio::Tools::ProteinToGenomeBlat object
 Returns : Bio::Tools::ProteinToGenomeBlat
 Args    : -filename
           -fh (filehandle)

=cut

sub new {
      my($class,@args) = @_;

      my $self = $class->SUPER::new(@args);
      $self->_initialize_io(@args);

      return $self;
}


=head2 next_result

 Title   : next_result
 Usage   : my $feat = $blat_parser->next_result
 Function: Get the next result set from parser data
 Returns : L<Bio::SeqFeature::Generic>
 Args    : none

=cut

sub next_result {
    my ($self) = @_;
    my $filehandle;
    
 my $line;

    my $id;
 while ($_=$self->_readline()){
   
    # first split on spaces:
    $line = $_;
    chomp $line;
   # chomp;
   
    my (
            $matches,      $mismatches,    $rep_matches, $n_count, $q_num_insert, $q_base_insert,
            $t_num_insert, $t_base_insert, $strand,      $q_name,  $q_length,     $q_start,
            $q_end,        $t_name,        $t_length,    $t_start, $t_end,        $block_count,
            $block_sizes,  $q_starts,      $t_starts
          )
          = split;

   
    my $superfeature = Bio::SeqFeature::Generic->new();
   
    # ignore any preceeding text
    unless ( $matches =~/^\d+$/ ){
      next;
    }
   
    # create as many features as blocks there are in each output line
    my (%gfeat, %pfeat);
    $gfeat{name} = $t_name;
    $pfeat{name} = $q_name;
   
    $pfeat{strand} = substr $strand,0,1;
    $gfeat{strand} = substr $strand,1,1;
   
   
    my $percent_id = sprintf "%.2f", ( 100 * ($matches + $rep_matches)/( $matches + $mismatches + $rep_matches )
);
   
   
    unless ( $q_length ){
      $self->warn("length of query is zero, something is wrong!");
      next;
    }
    my $score   = sprintf "%.2f", ( 100 * ( $matches + $mismatches + $rep_matches ) / $q_length );
   
    # size of each block of alignment (inclusive)
    my @block_sizes     = split ",",$block_sizes;
   
    # start position of each block (you must add 1 as psl output is off by one in the start coordinate)
    my @q_start_positions = split ",",$q_starts;
    my @t_start_positions = split ",",$t_starts;
   
    $superfeature->seq_id($q_name);
    $superfeature->score( $score );
    #$superfeature->percent_id( $percent_id );
    $superfeature->add_tag_value('percent_id',$percent_id);
    $superfeature->add_tag_value('ident',$matches);
    $superfeature->add_tag_value('qgap_cnt',$q_num_insert);
    $superfeature->add_tag_value('qgap_bases',$q_base_insert);
    $superfeature->add_tag_value('tgap_cnt',$t_num_insert);
    $superfeature->add_tag_value('tgap_bases',$t_base_insert);
    # each line of output represents one possible entire aligment of the query (gfeat) and the target(pfeat)
    for (my $i=0; $i<$block_count; $i++ ){
   

      my ($query_start,$query_end);

      if ( $pfeat{strand} eq '+' ){
        $query_start = $q_start_positions[$i] + 1;
        $query_end   = $query_start + $block_sizes[$i] - 1;
      }
      else{
        $query_end   = $q_length  - $q_start_positions[$i];
        $query_start = $query_end - $block_sizes[$i] + 1;
      }
   
      #$pfeat {start} = $q_start_positions[$i] + 1;
      #$pfeat {end}   = $pfeat{start} + $block_sizes[$i] - 1;
      $pfeat {start} = $query_start;
      $pfeat {end}   = $query_end;
      if ( $query_end <  $query_start ){
        $self->warn("dodgy feature coordinates: end = $query_end, start = $query_start. Reversing...");
        $pfeat {end}   = $query_start;
        $pfeat {start} = $query_end;
      }

      # set the start and end for the genomic coordinates.  must account
      # for codon size.
      if ( $gfeat{strand} eq '+' ){
        $gfeat {start} = $t_start_positions[$i] + 1;
        $gfeat {end}   = $gfeat{start} + 3*$block_sizes[$i] - 1;
      }
      else{
        $gfeat {end}   = $t_length  - $t_start_positions[$i];
        $gfeat {start} = $gfeat {end} - 3*$block_sizes[$i] + 1;
      }
   
      # we put all the features with the same score and percent_id
      $pfeat {score}   = $score;
      $gfeat {score}   = $pfeat {score};
      $pfeat {percent} = $percent_id;
      $gfeat {percent} = $pfeat {percent};
   
      # other stuff:
      $gfeat {db}         = undef;
      $gfeat {db_version} = undef;
      $gfeat {program}    = 'blat';
      $gfeat {p_version}  = '1';
      $gfeat {source}     = 'blat';
      $gfeat {primary}    = 'similarity';
      $pfeat {source}     = 'blat';
      $pfeat {primary}    = 'similarity';
   
      my $feature_pair = $self->create_feature(\%gfeat, \%pfeat);
      $superfeature->add_sub_SeqFeature( $feature_pair,'EXPAND');
    }
    #push(@features_within_features, $superfeature);
    return $superfeature; 
  }

}
=head2 create_feature

 Title   : create_feature
 Usage   : my $feat=$blat_parser->create_feature($feature,$seqname)
 Function: creates a SeqFeature Generic object
 Returns : L<Bio::SeqFeature::Generic>
 Args    :


=cut

sub create_feature {
    my ($self, $gfeat,$pfeat) = @_;



    my $feature1= Bio::SeqFeature::Generic->new( -seq_id     =>$gfeat->{name},
                                                 -start      =>$gfeat->{start},
                                                 -end        =>$gfeat->{end},
                                                 -strand     =>$gfeat->{strand},
                                                 -score      =>$gfeat->{score},
                                                 -source     =>$gfeat->{source},
                                                 -primary    =>$gfeat->{primary},
                                                   );
    


    my $feature2= Bio::SeqFeature::Generic->new( -seq_id     =>$pfeat->{name}, 
                                                 -start      =>$pfeat->{start},
                                                 -end        =>$pfeat->{end},
                                                 -strand     =>$pfeat->{strand},
                                                 -score      =>$pfeat->{score},
                                                 -source     =>$pfeat->{source},
                                                 -primary    =>$pfeat->{primary},
                                                  );




    my $featurepair = Bio::SeqFeature::FeaturePair->new;
    $featurepair->feature1 ($feature1);
    $featurepair->feature2 ($feature2);
   
   $featurepair->add_tag_value('evalue',$pfeat->{p});
   $featurepair->add_tag_value('percent_id',$pfeat->{percent});
   $featurepair->add_tag_value("hid",$pfeat->{primary});
    return  $featurepair; 
        
}


1;


