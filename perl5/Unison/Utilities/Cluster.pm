
package Unison::Utilities::Cluster;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use base 'Exporter';
our @EXPORT    = ();
our @EXPORT_OK = qw( cluster_data);

use Algorithm::Cluster qw/kcluster/;

sub new {
    my $self = {};

    bless $self;

    $self->{param}->{npass}     = 10;
    $self->{param}->{transpose} = 0;
    $self->{param}->{npass}     = 10;
    $self->{param}->{method}    = 'a';
    $self->{param}->{dist}      = 'e';

    $self->setParam(@_);

    if ( !defined( $self->{param}->{nclusters} ) ) {
        warn "number of clusters not set, will use default value of 4";
        $self->{param}->{nclusters} = 4;
    }
    if ( !defined( $self->{param}->{algorithm} ) ) {
        warn "Algorithm not set, will use default k-cluster";
        $self->{param}->{algorithm} = "kclust";
    }
    return $self;
}

## method: setParam(parameters)
## sets clustering parameters in hash-style key=>value
## format

sub setParam {

    my $self  = shift;
    my %param = @_;

    foreach my $p ( keys %param ) {
        $self->{param}->{$p} = $param{$p}
          if ( defined $param{$p} && $param{$p} ne "" );
    }
}

##
## Cluster values stored in a hash
## return 2D array of clusters
##
sub cluster_2dhash {

    my ( $self, $scores ) = @_;
    my ( @data, @mask, @weight );
    my ( $clusters, $centroids, $error, $found, $cluster_arr );
    my (%data_by_cluster);
    my $k = 0;

    foreach my $i ( keys %$scores ) {
        foreach my $j ( keys %{ $$scores{$i} } ) {
            if ( defined( $$scores{$i}{$j} ) ) {
                $data[$k] = [ $$scores{$i}{$j} ];
                ${ $mask[$k] }[0] = 1;
                $k++;
            }
        }
    }
    @weight = (1.0);

    #------------------
    # Define the params we want to pass to kcluster
    my %params = (
        nclusters => $self->{param}->{nclusters},
        transpose => $self->{param}->{transpose},
        npass     => $self->{param}->{npass},
        method    => $self->{param}->{method},
        dist      => $self->{param}->{dist},
        data      => \@data,
        mask      => \@mask,
        weight    => \@weight,
    );
    ( $clusters, $centroids, $error, $found ) = kcluster(%params);
    my $i = 0;
    foreach ( @{$clusters} ) {
        push @{ $data_by_cluster{$_} }, @{ $data[$i] };
        ++$i;
    }
    $i = 0;
    foreach ( @{$centroids} ) {
        my @min_max = sort { $a <=> $b } @{ $data_by_cluster{$i} };
        push @$cluster_arr, [@min_max];
        ++$i;
    }
    $self->{cluster_arr} = $cluster_arr;
    return $cluster_arr;
}

##
## sort the ranges
## return the association
## based on the sorted range
## the input value belongs to
##

sub get_association {
    my ( $self, $score, $order ) = @_;
    my $sc;

    if ( $order == -1 ) {
        @$sc = sort { $$b[0] <=> $$a[0] } @{ $self->{cluster_arr} };
    }
    else {
        @$sc = sort { $$a[0] <=> $$b[0] } @{ $self->{cluster_arr} };
    }
    foreach my $i ( 0 .. $self->{param}->{nclusters} - 1 ) {
        return ${ $self->{param}->{associate} }[$i]
          if ( $score <= $$sc[$i][ $#{ $$sc[$i] } ] and $score >= $$sc[$i][0] );
    }
    return ${ $self->{param}->{associate} }[ $self->{param}->{nclusters} ];
}

1;

