=head1 NAME

Unison::pseq -- Unison pseq table utilities
S<$Id: pseq.pm,v 1.7 2004/02/24 19:23:02 rkh Exp $>

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

my $seq = $u->get_sequence_by_pseq_id( 42 );

(etc.)

=head1 DESCRIPTION

B<> is a

=head1 ROUTINES AND METHODS

=cut

package Unison;
use CBT::debug;
use vars qw( %alias %md5 );
use Digest::MD5  qw(md5_hex);
CBT::debug::identify_file() if ($CBT::debug::trace_uses);



sub pseq_si_pseq_id {
  my ($self, $seq) = @_;
  $self->is_open()
  || croak("Unison connection not established");
  my $dbh = $self->{'dbh'};
  my $sth = $dbh->prepare_cached("select pseq_si_pseq_id(?)");
  print(STDERR $seq, "\n");
  my ($rv) = $dbh->selectrow_array($sth,undef,$seq);
  return $rv;

=pod

=over

=item B<$u-E<gt>>pseq_si_pseq_id( C<sequence> )

returns the pseq_id for a given sequence, creating it if necessary

=back

=cut
}


sub get_sequence_by_pseq_id($) {
  my ($self,$pseq_id) = @_;
  $self->is_open()
  || croak("Unison connection not established");
  my $sth = $self->prepare_cached("select seq from pseq where pseq_id=?");
  $sth->execute($pseq_id);
  my ($rv) = $sth->fetchrow_array();
  $sth->finish();
  return $rv;

=pod

=over

=item B<$u-E<gt>>get_sequence_by_pseq_id( C<pseq_id> )

fetches a single protein sequence from the pseq table.

=back

=cut
}



sub best_alias {
  my $self = shift;
  $self->is_open()
  || croak("Unison connection not established");
  ($#_ >= 0)
  || croak("usage: best_alias(pseq_id [,anyalias])\n");
  my $sth;
  if ($#_ == 0 ) {
  $sth = $self->prepare_cached("select best_alias(?)");
  $sth->execute($_[0]);
  } else {
  $sth = $self->prepare_cached("select best_alias(?,?)");
  $sth->execute( $_[0], ($_[1] == '1' ? 'true' : 'false') );
  }
  my $ba = $sth->fetchrow_array;
  $sth->finish();
  return( $ba );

=pod

=over

=item B<$u-E<gt>>best_alias( C<pseq_id> )

return the `best_alias' as determined heuristically by Unison.
Briefly, the best_alias is the one specified by the pseq.palias_id if
not null, or the first preference-ordered list of aliases based on
porigin.ann_pref ranking.  See also best_annotation.

=back

=cut
}


sub best_annotation {
  my $self = shift;
  $self->is_open()
  || croak("Unison connection not established");
  ($#_ >= 0)
  || croak("usage: best_annotation(pseq_id [,anyalias])\n");
  my $sth;
  if ($#_ == 0 ) {
  $sth = $self->prepare_cached("select best_annotation(?)");
  $sth->execute($_[0]);
  } else {
  $sth = $self->prepare_cached("select best_annotation(?,?)");
  $sth->execute( $_[0], ($_[1] == '1' ? 'true' : 'false') );
  }
  my $ba = $sth->fetchrow_array;
  $sth->finish();
  return( $ba );

=pod

=over

=item B<$u-E<gt>>best_annotation( C<pseq_id> )

return the "best_annotation" as determined heuristically by Unison.
Compare with the C<best_alias> method and see that for a definition of
"best".

=back

=cut
}


sub pseq_get_aliases {
  my $self = shift;
  $self->is_open()
  || croak("Unison connection not established");
  ($#_==0)
  || croak("exactly one porigin_id needed\n");
  my $pseq_id = shift;
  my $sql = "select origin||':'||alias from palias as a join porigin as o on a.porigin_id=o.porigin_id  where pseq_id=$pseq_id  order by o.ann_pref";
  return( map {@$_} @{ $self->{'dbh'}->selectall_arrayref($sql) } );

=pod

=over

=item B<$u-E<gt>>pseq_get_aliases( C<pseq_id> )

return a list of <origin>:<alias> annotations for a given pseq_id, ordered
by porigin.ann_pref.

=back

=cut
}


sub pseq_id_by_md5 {
  my $self = shift;
  $self->is_open()
  || croak("Unison connection not established");
  ($#_==0)
  || croak("exactly one md5 needed\n");
  my $md5 = lc(shift);
  my $sql = "select pseq_id from pseq where md5='$md5'";
  return( map {@$_} @{ $self->{'dbh'}->selectall_arrayref($sql) } );

=pod

=over

=item B<$u-E<gt>>pseq_id_by_md5( C<md5> )

return a list of pseq_id for a given md5 checksum

=back

=cut
}


sub pseq_id_by_sequence {
  my $self = shift;
  $self->is_open()
  || croak("Unison connection not established");
  ($#_==0)
  || croak("exactly one sequence needed\n");
  my $seq = uc(shift);
  my $sth = "select _pseq_seq_lookup(?)";
  return( map {@$_} @{ $self->{'dbh'}->selectall_arrayref($sth,undef,$seq) } );

=pod

=over

=item B<$u-E<gt>>pseq_id_by_sequence( C<sequence> )

return the pseq_id for a given sequence

=back

=cut
}


#-------------------------------------------------------------------------------
# NAME: process_stream
# PURPOSE: parse Bio::SeqIO stream and load sequences into Unison
# ARGUMENTS: Bio::SeqIO object, option hashref:
#   'origin' => name of porigin (REQUIRED)
#   'start-after' => skip seqs until this accession
#   'sql-only' => boolean for sql output only (no loading in Unison)
#   'incl-subex' => boolean for whether to include subex gene predictions
#   'verbose' => boolean for whether to output more information
# RETURNS: hash with process info keys: nseen, nskipped, nadded
#-------------------------------------------------------------------------------
sub process_stream {
  my ($u,$in,$opts) = @_;
  my %rv = ( nseen => 0, nskipped => 0, nadded => 0 );
  $opts->{porigin_id} = $u->porigin_si_porigin_id($opts->{origin});
  while( my $bs = $in->next_seq() ) {
    $u->process_seq($bs,$opts,\%rv);
  }
  return(\%rv);
}


#-------------------------------------------------------------------------------
# NAME: process_seq
# PURPOSE: parse Bio::Seq object and load seq and alia into Unison
# ARGUMENTS: Bio::Seq object, option hashref, process info hashref (keys: nseen, nskipped, nadded)
# RETURNS: nada
#-------------------------------------------------------------------------------
sub process_seq  {
  my ($u,$bs,$opts,$rv) = @_;
  my $id = $bs->display_id();
  my $seq = $bs->seq();

  if (not defined $seq)  {
    warn("$id: sequence not defined\n"); 
    return;
  }

  my $tax_id;
  my $descr = $bs->desc();
  my $oseq = $seq;
  $seq = uc($seq); $seq =~ s/[^-\*\?A-Z]//g;
  my $md5 = &md5_hex($seq);
  $rv->{nseen}++;

  # description reformatting
  $descr = '' unless defined $descr;
  $descr =~ s/\s{2,}/ /g;
  $descr =~ s/^\s+//;
  $descr =~ s/\s+$//;
  if ($opts->{origin} =~ m/spdi/i) {
  $descr =~ s/\[(?:min|full)\]\s+//;
  $descr =~ s/\# converted.+//;
  }

  # skip sequences in various conditions
  my $skip;
  if ($id !~ m/\w/)  {
    $skip = "doesn't look like a valid sequence id"; 
  } elsif (defined $opts->{'start-after'})  {
    $skip = "haven't reached $opts->{'start-after'} yet";
    undef $opts->{'start-after'} if ($id eq $opts->{'start-after'});
  } elsif (%alias and exists $alias{$id}) {
    $skip = 'extant alias';
  } elsif (length($seq) == 0) {
    $skip = "zero-length";
  } elsif (!$opts->{'incl-subex'} and $descr =~ m%/type=(\w+)% and $1 ne 'gene') {
    $skip = "non-gene genescan transcript";
  }
  if (defined $skip) {
    warn("# skipping $id: $skip ($descr)\n") if $opts->{verbose};
    $rv->{nskipped}++;
    return;
  }

  # @ids is the SET of ids to which we'll link this sequence
  my @ids = ();

  if ($opts->{origin} =~ m/SPDI/i) {
    my %ids;
    # NO UNQs in database -- not unique!
    $ids{$1}++ if $descr =~ s/(UNQ\d+)\s+//;
    $ids{$1}++ if $descr =~ s/(PRO\d+)\s+//;
    $ids{$1}++ if $descr =~ s/(DNA\d+)\s+//;
    $ids{$id}++;
    @ids = sort keys %ids;
    #warn("! $id: SPDI sequence didn't match 2 identifiers (@ids)\n") unless $#ids==1;
  } else {
    @ids = ( $id );
  }

  if ($opts->{'sql-only'}) {
    printf("insert into pseq (seq,len) values ('$seq',%d);\n",
      length($seq)); return 1;
  }

  # select/insert sequences, then link aliases
  my $pseq_id;
  my $frommd5='';
  if (%md5 and exists $md5{ $md5 })  {
    $pseq_id = $md5{ $md5 };
    $frommd5='*';
  } else {
    $pseq_id = $u->pseq_si_pseq_id( $seq );
    $md5{ $md5 } = $pseq_id;
  }

  if (not defined $pseq_id)  {
    warn("! failed to add $id"); 
    return 0;
  }

  # see if there's species info.  if so, get the tax_id to insert with the
  # alias
  if (defined $bs->species && defined $bs->species->ncbi_taxid()) {
    $tax_id = $bs->species->ncbi_taxid();
  } else {
    $tax_id = 'NULL';
  }

  foreach my $upd_id (@ids)  {
    $u->add_palias($pseq_id,$opts->{porigin_id},$upd_id,$descr,$tax_id);
  }

  printf(STDERR "## added pseq_id=$pseq_id$frommd5, len=%d, aliases={@ids}, descr=%s\n",
    length($seq), $descr) if $opts->{verbose};
  $rv->{nadded}++;

  return;
}


### DEPRECATED FUNCTIONS

sub get_seq {
  warn_deprecated();
  my $self = shift;
  return $self->get_sequence_by_pseq_id(@_);
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
