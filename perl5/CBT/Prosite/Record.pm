##############################################################################
## Nothing to modify beyond this line
##############################################################################

=head1 NAME

tflush -- hydrostatic flow controller

S<$Id: Record.pm,v 0.5 1999/10/09 14:58:52 reece Exp $>

=head1 SYNOPSIS

C<tflush [time]>

=head1 DESCRIPTION

B<tflush> flushes toilet remotely in case you realize that you forgot this

=head1 INSTALLATION

@@banner@@

=cut

##############################################################################
## Nothing to modify beyond this line
##############################################################################

BEGIN {
    $RCSHeader =
'$Header: /mnt/cvs/cbc/opt/lib/perl5/Prosite/Record.pm,v 0.5 1999/10/09 14:58:52 reece Exp $ ';
    print("# $RCSHeader\n") if ( defined $main::DEBUG and $main::DEBUG );
}

package CBT::Prosite::Record;
use CBT::EBI::Record;
@ISA = qw( CBT::EBI::Record );

# ===========================================================================
# lists of AC
sub set_positives    # := tp U fn U potentials
{
    $_[0]->extract_DR('[TNP]');
}
sub all_positives     { $_[0]->extract_DR('[TF\?]'); }
sub true_positives    { $_[0]->extract_DR('T'); }
sub false_negatives   { $_[0]->extract_DR('N'); }
sub potentials        { $_[0]->extract_DR('P'); }
sub false_positives   { $_[0]->extract_DR('F'); }
sub unknown_positives { $_[0]->extract_DR('\?'); }

sub extract_DR_as_AC    # extract AC
{
    exists $_[0]->{'DR'} ? $_[0]->{'DR'} =~ m/\w+, (\w+)\s*, $_[1]/g : ();
}

sub extract_DR {
    exists $_[0]->{'DR'} ? $_[0]->{'DR'} =~ m/(\w+), \w+\s*, $_[1]/g : ();
}

# ===========================================================================
# Counts from NR
sub nTotal           { $_[0]->NR =~ m/TOTAL=(\d+)\((\d+)\)/     && ( $1, $2 ) }
sub nTruePositive    { $_[0]->NR =~ m/POSITIVE=(\d+)\((\d+)\)/  && ( $1, $2 ) }
sub nUnknownPositive { $_[0]->NR =~ m/UNKNOWN=(\d+)\((\d+)\)/   && ( $1, $2 ) }
sub nFalsePositive   { $_[0]->NR =~ m/FALSE_POS=(\d+)\((\d+)\)/ && ( $1, $2 ) }
sub nFalseNegative   { $_[0]->NR =~ m/FALSE_NEG=(\d+)/          && $1 }
sub nPartial         { $_[0]->NR =~ m/PARTIAL=(\d+)/            && $1 }

# ===========================================================================
sub PDB {
    my ($self) = @_;
    return
      exists $self->{'3D'}
      ? map { $_ = lc($_) } $self->{'3D'} =~ m/(\w{4})\;/g
      : ();
}

# ===========================================================================
sub sprelease {
    my ($self) = @_;
    if ( not exists $self->{sprelease} ) {
        ( $self->{sprelease} ) = $self->{NR} =~ m%/RELEASE=(\d+)%;
    }
    return ( $self->{sprelease} );
}

# ===========================================================================
sub spsequences {
    my ($self) = @_;
    if ( not exists $self->{spsequences} ) {
        ( $self->{spsequences} ) = $self->{NR} =~ m%/RELEASE=\d+,(\d+)%;
    }
    return ( $self->{spsequences} );
}

# ===========================================================================
sub taxo_range {
    my ($self) = shift;
    if ( not exists $self->{'taxo_range'} ) {
        ( $self->{'taxo_range'} ) =
          exists $self->{'CC'}
          ? $self->{'CC'} =~ m%/TAXO-RANGE=(.{5})%
          : undef;
    }
    return ( $self->{'taxo_range'} );
}

# ===========================================================================
sub max_repeat {
    my ($self) = shift;
    if ( not exists $self->{'sites'} ) {
        ( $self->{'max_repeat'} ) =
          exists $self->{'CC'}
          ? $self->{'CC'} =~ m%/MAX-REPEAT=(\d+)%
          : undef;
    }
    return ( $self->{'max_repeat'} );
}

# ===========================================================================
sub sites {
    my ($self) = shift;
    if ( not exists $self->{'sites'} ) {
        $self->{'sites'} = undef;
        if ( exists $self->{'CC'} and $self->{'CC'} =~ m%/SITE=\d+,[^;]+% ) {
            my $x = $self->{'CC'};
            @{ $self->{sites} } =
              map { s%,%/%; $_ } $self->{'CC'} =~ m%/SITE=(\d+,[^;]+)%g;
        }
    }
    return @{ $self->{'sites'} };
}

# ===========================================================================
sub regexp {
    my ($self) = @_;
    local ($_) = $self->{PA};
    s/\{(\w+)\}/[^$1]/g;      # {xyz} -> [^xyz]
    s/\(([^\)]+)\)/{$1}/g;    # () -> {}
    s/x/./g;                  # x -> .
    s/-|\s|\.$//g;            # del -, whitespace, and terminal .
    s%\[(\^?)([^\]]+)\]%"[$1".join('',sort split //,$2)."]"%ge; # sort [] tokens
    s%\[<(.*)\]%(?:^|$1)%;                                      # ^ inside []
    s%\[>(.*)\]%(?:\$|$1)%;                                     # $ inside []
    s%^<%^%;
    s%>$%\$%;
    return ($_);
}

# ===========================================================================
sub match

  # match pattern to sequence
  # in scalar context, return number of matches
  # in array context, return array of indices at which pattern patches
{
    my ( $self, $seq ) = @_;
    my ($re) = $self->regexp;
    if (wantarray) {
        return ( map { pos($seq) } $seq =~ m/$re/g );
    }
    my $count;
    $count++ while ( $seq =~ m/$re/g );
    return $count;
}

# ===========================================================================
sub matches

  # return 1 if pattern matches seqeunce
{
    my ( $self, $seq ) = @_;
    my $r = $self->match($seq);

    #my($mr) = $self->max_repeat;   # M-R is NOT a criterion for matching
    return ($r);    # and ( not defined($mr) or ($r<=$mr) ) );
}

# ===========================================================================
sub partition_ACs

  # For an array of ACs, partition into TP, UP, FP, FN sets by comparison
  # with GLOBAL data %SP, %SU, and @SP.
{
    my ( $self, $PPr ) = @_;    # PP = Pattern Positives
    my (%PP) = map { $_ => 1 } @$PPr;
    my (@SP) = $self->set_positives;
    my (%SP) = map { $_ => 1 } @SP;
    my (%SU) = map { $_ => 1 } $self->unknown_positives;    # unknown positives
    my ( @TP, @UP, @FP, @FN );
    my ($AC);
    foreach $AC (@$PPr) {
        if    ( exists $SP{$AC} ) { push( @TP, $AC ) }      # TP = PP ^ SP
        elsif ( exists $SU{$AC} ) { push( @UP, $AC ) }      # UP = PP ^ UP
        else                      { push( @FP, $AC ) }      # otherwise
    }
    @FN = grep { not exists $PP{$_} } @SP;                  # FN = SP ^ not PP
    return ( \@TP, \@UP, \@FP, \@FN );
}

# ===========================================================================
sub dump {
    my ($self) = shift;
    print("calling inherited dump\n");
    $self->SUPER::dump();
    my ( $x, @x );
    $x = $self->taxo_range;
    print( "TAXO-RANGE = ", defined $x ? $x : 'N/A', "\n" );
    $x = $self->max_repeat;
    print( "MAX-REPEAT = ", defined $x ? $x : 'N/A', "\n" );
    @x = $self->sites;
    printf( "%d sites = {%s}\n", $#x + 1, join( ',', @x ) );
}

1;
