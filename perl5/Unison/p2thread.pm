=head1 NAME

Unison::p2thread -- Unison p2thread table utilities
S<$Id: p2thread.pm,v 1.1 2003/06/10 20:27:33 cavs Exp $>

=head1 SYNOPSIS

 use Unison;

 my $u = new Unison;

 my $seq = $u->delete1thread( 

(etc.)

=head1 DESCRIPTION

B<> is a

=head1 ROUTINES AND METHODS

=cut

package Unison;

my %uf = (
   'raw' => 'raw_score',
   'svm' => 'svm_score',
   'zscore' => 'z_score',
   'mutation' => 'mutation_score',
   'singleton' => 'singleton_score',
   'pairwise' => 'pair_score',
   'ssfit' => 'ssfit_score',
   'gap' => 'gap_score',
   'nident' => 'identities',
   'nalign' => 'align_len',
   'rgyr' => 'rgyr',
   'start' => 'qstart',
   'stop' => 'qend',
);


#-------------------------------------------------------------------------------
# insert_thread()
#-------------------------------------------------------------------------------
                                                                                                                                              
=head2 insert_thread()
                                                                                                                                              
 Name:      insert_thread()
 Purpose:   insert 1 Prospect2::Thread object into the database
 Arguments: Unison connection, pseq_id, p2params_id, 
            Prospect2::ThreadSummary or Prospect2::Thread
 Returns:   nada
                                                                                                                                              
=cut

sub insert_thread {
  my ($u,$pseq_id,$p2params_id,$t) = @_;
 
  # check parameters
  if      ( !defined $pseq_id or $pseq_id !~ m/^\d+$/ ) {
    throw Unison::BadUsage( "insertThread() pseq_id provided is missing or invalid" );
  } elsif ( !defined $p2params_id or $p2params_id !~ m/^\d+$/ ) {
    throw Unison::BadUsage( "insertThread() p2params_id provided is missing or invalid" );
  } elsif  ( !defined $t or (ref $t !~ m/Prospect2::Thread/ )) {
    throw Unison::BadUsage( "insertThread() thread provided is missing or invalid" );
  }
 
  # get the model id for the template name given
  my $pmodel_id = $u->get_pmodel_id($t->tname);
  if ( !defined $pmodel_id or $pmodel_id eq '' ) {
    throw Unison::BadUsage( "insertThread() pmodel_id doesn't exist for template name: " . $t->name() );
  }
 
  # build key/values for sql insert
  my @keys = ('pseq_id','p2params_id','pmodel_id',keys %uf );
  my @values = ( $pseq_id,$p2params_id, $pmodel_id, map { $t->{$uf{$_}} } keys %uf );
 
  throw Unison::BadUsage( "keys (" . $#keys+1 . ") != values (" . $#values+1 . ")\n" ) if $#keys != $#values;
 
  my $sql = 'insert into p2thread (' .  join(',',@keys) .  ') values (' .
    join(',',map { '?' } @keys) .  ')';
  my $show_sql = "insert into p2thread (" .  join(',',@keys) .  ") values (" .
     join(',',map { defined $_ ? $_ : '' } @values) . ")";
  print "insertThread(): $show_sql\n" if $ENV{'DEBUG'};
  my $sth = $u->prepare_cached($sql);
  $sth->execute( @values );
  $sth->finish();
}


#-------------------------------------------------------------------------------
# delete_thread()
#-------------------------------------------------------------------------------
                                                                                                                                              
=head2 delete_thread()
                                                                                                                                              
 Name:      delete_thread()
 Purpose:   delete 1 Prospect2::Thread object into the database
 Arguments: Unison connection, pseq_id, p2params_id, 
            Prospect2::ThreadSummary or Prospect2::Thread
 Returns:   nada
                                                                                                                                              
=cut

sub delete_thread {
  my ($u,$pseq_id,$p2params_id,$t) = @_;
                                                                                                                                              
  # check parameters
  if      ( !defined $pseq_id or $pseq_id !~ m/^\d+$/ ) {
    throw Unison::BadUsage( "delete_thread() pseq_id provided is missing or invalid" );
  } elsif ( !defined $p2params_id or $p2params_id !~ m/^\d+$/ ) {
    throw Unison::BadUsage( "delete_thread() p2params_id provided is missing or invalid" );
  } elsif  ( !defined $t or (ref $t !~ m/Prospect2::Thread/ )) {
    throw Unison::BadUsage( "delete_thread() thread provided is missing or invalid" );
  }

                                                                                                                                              
  # get the model id for the template name given
  my $pmodel_id = $u->get_pmodel_id($t->tname);
  if ( !defined $pmodel_id or $pmodel_id eq '' ) {
    throw Unison::RuntimeError( "deleteThread() pmodel_id doesn't exist for template name: " . $t->name() );
  }
                                                                                                                                              
  # build key/values for sql insert
  my @keys = ('pseq_id','p2params_id','pmodel_id',keys %uf );
  my @values = ( $pseq_id,$p2params_id, $pmodel_id, map { $t->{$uf{$_}} } keys %uf );
                                                                                                                                              
  my $sql = 'delete from p2thread where pseq_id=? and p2params_id=? and pmodel_id=?';
  my $show_sql = "delete from p2thread where pseq_id=$pseq_id and p2params_id=$p2params_id and pmodel_id=$pmodel_id";
  print "deleteThread(): $show_sql\n" if $ENV{'DEBUG'};
                                                                                                                                              
  my $sth = $u->prepare_cached($sql);
  $sth->execute( $pseq_id,$p2params_id, $pmodel_id );
  $sth->finish();
}


#-------------------------------------------------------------------------------
# get_pmodel_id()
#-------------------------------------------------------------------------------

=head2 get_pmodel_id()

 Name:      get_pmodel_id()
 Purpose:    retrieve the pmodel_id for a given model name (e.g. template name)
 Arguments: model name
 Returns:   pmodel_id

=cut

my %pmodel_id;
sub get_pmodel_id
  {
  my ($u,$modn) = @_;
  if (not exists $pmodel_id{$modn})
  {
  my $sth = $u->prepare_cached('select pmodel_id from p2template where name=?');
  $sth->execute($modn);
  ($pmodel_id{$modn}) = $sth->fetchrow_array();
  $sth->finish();
  }
  return $pmodel_id{$modn};
  }

#-------------------------------------------------------------------------------


1;
