=head1 NAME

Unison::paprospect2 -- Unison paprospect2 table utilities
S<$Id: paprospect2.pm,v 1.7 2004/03/31 18:02:38 cavs Exp $>

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
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;


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
 Purpose:   insert 1 Bio::Prospect::Thread object into the database
 Arguments: Unison connection, pseq_id, params_id, 
            Bio::Prospect::ThreadSummary or Bio::Prospect::Thread
 Returns:   nada

=cut

sub insert_thread {
  my ($u,$pseq_id,$params_id,$t) = @_;

  # check parameters
  if      ( !defined $pseq_id or $pseq_id !~ m/^\d+$/ ) {
    throw Unison::BadUsage( "insertThread() pseq_id provided is missing or invalid" );
  } elsif ( !defined $params_id or $params_id !~ m/^\d+$/ ) {
    throw Unison::BadUsage( "insertThread() params_id provided is missing or invalid" );
  } elsif  ( !defined $t or (ref $t !~ m/Bio::Prospect::Thread/ )) {
    throw Unison::BadUsage( "insertThread() thread provided is missing or invalid" );
  }

  # get the model id for the template name given
  my $pmodel_id = $u->get_pmodel_id($t->tname);
  if ( !defined $pmodel_id or $pmodel_id eq '' ) {
    throw Unison::BadUsage( "insertThread() pmodel_id doesn't exist for template name: " . $t->name() );
  }

  # build key/values for sql insert
  my @ufs = keys %uf;
  my @k = ('pseq_id','params_id','pmodel_id',@ufs );
  my @v = ( $pseq_id,$params_id, $pmodel_id, map { $t->{$uf{$_}} } @ufs );

  throw Unison::BadUsage( "keys (" . $#k+1 . ") != values (" . $#v+1 . ")\n" ) if $#k != $#v;

  my $sql = 'insert into paprospect2 (' .  join(',',@k) .  ') values (' .
    join(',',map { '?' } @k) .  ')';
  my $show_sql = "insert into paprospect2 (" .  join(',',@k) .  ") values (" .
     join(',',map { defined $_ ? $_ : '' } @v) . ")";
  print "insertThread(): $show_sql\n" if $ENV{'DEBUG'};
  my $sth = $u->prepare_cached($sql);
  $sth->execute( @v );
  $sth->finish();
}


#-------------------------------------------------------------------------------
# delete_thread()
#-------------------------------------------------------------------------------

=head2 delete_thread()

 Name:      delete_thread()
 Purpose:   delete 1 Bio::Prospect::Thread object into the database
 Arguments: Unison connection, pseq_id, params_id, 
            Bio::Prospect::ThreadSummary or Bio::Prospect::Thread
 Returns:   nada

=cut

sub delete_thread {
  my ($u,$pseq_id,$params_id,$t) = @_;
  # check parameters
  if      ( !defined $pseq_id or $pseq_id !~ m/^\d+$/ ) {
    throw Unison::BadUsage( "delete_thread() pseq_id provided is missing or invalid" );
  } elsif ( !defined $params_id or $params_id !~ m/^\d+$/ ) {
    throw Unison::BadUsage( "delete_thread() params_id provided is missing or invalid" );
  } elsif  ( !defined $t or (ref $t !~ m/Bio::Prospect::Thread/ )) {
    throw Unison::BadUsage( "delete_thread() thread provided is missing or invalid" );
  }

  # get the model id for the template name given
  my $pmodel_id = $u->get_pmodel_id($t->tname);
  if ( !defined $pmodel_id or $pmodel_id eq '' ) {
    throw Unison::RuntimeError( "deleteThread() pmodel_id doesn't exist for template name: " . $t->name() );
  }

  my $sql = 'delete from paprospect2 where pseq_id=? and params_id=? and pmodel_id=?';
  my $show_sql = "delete from paprospect2 where pseq_id=$pseq_id and params_id=$params_id and pmodel_id=$pmodel_id";
  print "deleteThread(): $show_sql\n" if $ENV{'DEBUG'};

  my $sth = $u->prepare_cached($sql);
  $sth->execute( $pseq_id, $params_id, $pmodel_id );
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
sub get_pmodel_id {
  my ($u,$modn) = @_;
  if (not exists $pmodel_id{$modn})	{
	my $sth = $u->prepare_cached('select pmodel_id from pmprospect2 where acc=?');
	$sth->execute($modn);
	($pmodel_id{$modn}) = $sth->fetchrow_array();
	$sth->finish();
  }
  return $pmodel_id{$modn};
}

#-------------------------------------------------------------------------------





1;
