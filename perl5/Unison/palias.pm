=head1 NAME

Unison::palias -- Unison palias table utilities
S<$Id: palias.pm,v 1.2 2003/06/11 00:17:05 cavs Exp $>

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

=head1 DESCRIPTION

B<> is a

=head1 ROUTINES AND METHODS

=cut

package Unison;

sub add_palias
  {
  my $self = shift;
  $self->is_open()
  || croak("Unison connection not established");
  my ($pseq_id,$porigin_id,$alias,$descr) = @_;
  if (defined $descr and $descr =~ /\w/)
  {
  $descr =~ s/([\'])/\\$1/g;
  $descr =~ s/^\s+//; $descr =~ s/\s+$//; $descr =~ s/\s{2,}/ /;
  $descr = "'$descr'";
  }
  else
  { $descr = 'NULL'; }

  if ( not defined $pseq_id 
     or not defined $porigin_id
     or not defined $alias 
     or not defined $descr)
  {
  confess(sprintf("<pseq_id,porigin_id,alias,descr>=<%s,%s,%s,%s>",
          defined $pseq_id ? $pseq_id : 'undef',
          defined $porigin_id ? $porigin_id : 'undef',
          defined $alias ? $alias : 'undef',
          defined $descr ? $descr : 'undef' ));
  }

  $self->do( "insert into palias (pseq_id,porigin_id,alias,descr) "
       . "values ($pseq_id,$porigin_id,'$alias',$descr)",
         { PrintError=>0 } );
  return;
  }


=pod

=over

=item B<Unison::add_palias_id( C<pseq_id,porigin_id,alias,descr> )>

=back

=cut


#-------------------------------------------------------------------------------
# get_pseq_id_from_alias()
#-------------------------------------------------------------------------------

=head2 get_pseq_id_from_alias()

 Name:      get_pseq_id_from_alias()
 Purpose:   get a pseq_id given an alias
 Arguments: palias
 Returns:   pseq_id

=cut

sub get_pseq_id_from_alias {
  my ($u,$alias) = @_;

  $u->is_open() || throw Unison::RuntimeError("Unison connection not established");
  throw Unison::RuntimeError("Unison connection not established")
    if ! defined $alias;
  my $sth = $u->prepare_cached("select best_pseq_id(?)");
  $sth->execute($alias);
  my $ba = $sth->fetchrow_array;
  $sth->finish();
  return( $ba );
}


=pod

=head1 BUGS

=head1 SEE ALSO

=head1 AUTHOR

 Reece Hart, Ph.D.                     rkh@gene.com, http://www.gene.com/
 Genentech, Inc.                       650/225-6133 (voice), -5389 (fax)
 Bioinformatics Department
 1 DNA Way, MS-93                      http://www.in-machina.com/~reece/
 South San Francisco, CA  94080-4990   reece@in-machina.com, GPG: 0x25EC91A0

=cut


1;
