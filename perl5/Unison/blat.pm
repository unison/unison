package Unison;



#-------------------------------------------------------------------------------
# NAME: get_blataln
# PURPOSE: retrieve blataln info
#-------------------------------------------------------------------------------
sub get_blataln {
  my ($u, $pseq_id) = @_;

  my $sql = "select chr,gstart,gstop,p2gblataln_id from blatloci where pseq_id=?";

  my $sth = $u->prepare($sql);
  $sth->execute($pseq_id);

  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my @f;
  foreach my $r ($sth->fetchrow_hashref) {
    return $r->{chr},$r->{gstart},$r->{gstop},$r->{p2gblataln_id};
  }
}


#-------------------------------------------------------------------------------
# NAME: get_blataln_id
# PURPOSE: retrieve blataln_ids for a given genomic region
#-------------------------------------------------------------------------------
sub get_blataln_id {
  my ($u, $genasm_id, $chr, $gstart, $gstop) = @_;

  my $sql = "select ah.p2gblataln_id from p2gblatalnhsp ah, p2gblathsp h where " .
    "h.gstart>=$gstart and h.gstop<=$gstop and h.chr=$chr and h.genasm_id=$genasm_id " .
    "and ah.p2gblathsp_id=h.p2gblathsp_id";
  my $sth = $u->prepare($sql);
  $sth->execute();
  print(STDERR $sql, ";\n\n") if $opts{verbose};
  my @retval;
  while ( my $row = $sth->fetchrow_arrayref() ) {
    push @retval,$row->[0];
  }
  return(@retval);
}

1;
