package CBT::EBI::File;
use base 'IO::File';

our $/ = "\n//\n";

# why doesn't the following work?
#use overload '<>' => \&read1;

sub read1block {
  my $self = shift;
  my $in = $self->getline();
  chomp $in;
  return $in;
}



sub __extract_field($$) {
  my ($blk,$fld) = @_;
  my $rv;
  while( $blk =~ m/^$fld\s+(.+\n)/mg ) {
	$rv = '' unless defined $rv;
	$rv .= $1;
  }
  return $rv;
}

1;
