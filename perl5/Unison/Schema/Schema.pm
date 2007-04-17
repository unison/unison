package Unison;

sub get_table_info($) {
  # get_table_info -- aggregate FK-PK relationships by FK table
  # The primary use of this is to represent the PK dependencies for each
  # table to assemble JOIN restrictions during dumping.

  my $u = shift;
  my %tables;
  my $sth = $u->prepare( q(
				  			SELECT fk_namespace,fk_relation,fk_column,
								   pk_namespace,pk_relation,pk_column,ud,fk_notnull
							FROM pgutils.foreign_keys
				            ) );
  $sth->execute();
  my $nfks;
  while( my $row = $sth->fetchrow_hashref() ) {
	$nfks++;

	my $pkst = "$row->{pk_namespace}.$row->{pk_relation}";
	$tables{$pkst} = Unison::Schema::Table->new( 'st' => $pkst ) unless exists $tables{$pkst};

	my $fkst = "$row->{fk_namespace}.$row->{fk_relation}";
	$tables{$fkst} = Unison::Schema::Table->new( 'st' => $fkst ) unless exists $tables{$fkst};

	my %fk_data = ( (map { $_ => $row->{$_} } qw(fk_column pk_namespace pk_relation pk_column ud)), 
					pkt => $tables{pkst} );
	$tables{$fkst}->add_fk( \%fk_data );
  }
  $sth->finish();

  return %tables;
}
