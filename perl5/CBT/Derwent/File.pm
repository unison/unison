package CBT::Derwent::File;
use warnings;
use strict;
use base 'CBT::EBI::File';
use CBT::Derwent::Record;

#our $/ = "\n//\n";

sub read1 {
  my $self = shift;
  my $blk = $self->read1block();
  return unless defined $blk;
  chomp $blk;
  return __parse_block( $blk );
}



## INTERNAL:
sub __parse_block {
  my $blk = shift;
  return if $blk !~ m/^ID/;
  my $r = new CBT::Derwent::Record( $blk );
  $r->{ID} = __extract_field($blk,'ID', qw(\s.*\n) );
  $r->{AC} = __extract_field($blk,'AC', qw(;.*\n)  );

  $r->{PT} = __extract_field($blk,'PT', qw(\.\n) );
  $r->{PT} =~ s/\s+/ /gm if defined $r->{PT};
  $r->{KW} = __extract_field($blk,'KW', qw(\.\n) );
  $r->{KW} =~ s/\s+/ /gm if defined $r->{KW};

  $r->{OS} = __extract_field($blk,'OS', qw(\.) );
  $r->{PN} = __extract_field($blk,'PN', qw(\.\n) );
  $r->{PF} = __extract_field($blk,'PF', qw(\.$) );
  $r->{PD} = __extract_field($blk,'PD', qw(\.$) );
  $r->{PS} = __extract_field($blk,'PS', qw(\.$) );

  $r->{PR} = __extract_field($blk,'PR');
  $r->{DT} = __extract_field($blk,'DT');
  $r->{PI} = __extract_field($blk,'PI');
  $r->{PA} = __extract_field($blk,'PA');
  $r->{CC} = __extract_field($blk,'CC');
  $r->{DR} = __extract_field($blk,'DR');
  $r->{DE} = __extract_field($blk,'DE');

  $r->{SQ} = __extract_sequence($blk);

  return $r;
}


sub __extract_field($$;$) {
  my ($blk,$fld) = (shift,shift);
  my $rv;
  while( $blk =~ m/^$fld\s+(.+\n?)/gm ) {
	$rv = '' unless defined $rv;
	$rv .= $1;
  }
  if (defined $rv) {
	$rv =~ s/$_// for @_;
  }
  return $rv;
}

sub __extract_sequence($) {
  my ($blk) = @_;
  my $seq = __extract_field($blk,' ');
  $seq =~ s/\d+$//gm;
  $seq =~ s/\s+//gm;
  $seq = uc($seq);

  my $SQ = __extract_field($blk,'SQ');
  my ($n) = $SQ =~ m/Sequence\s+(\d+)/;
  if (defined $n) {
	my $l = length($seq);
	if ($n != $l) {
	  warn("sequence length ($l) != advertised length ($n) in\nseq=$seq\nblk=$SQ");
	}
  } else {
	die("\n! couldn't extract sequence length from $SQ\n");
  }

  return $seq;
}


1;
