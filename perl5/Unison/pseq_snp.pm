#!/usr/bin/env perl
$ID = $Id$;
#represents a single snp in a given sequence
package Unison::pseq_snp;

use strict;
use Carp;

use vars qw( $VERSION );

sub new {
    my ($class,$opts) = @_;
    my $self = {};
    bless $self,$class;
    if(!defined($opts->{'pseq_id'})) {
        warn "pseq_snp needs an pseq_id to initialize\n";
        return undef;
    }
    else {$self->{'pseq_id'} = $opts->{'pseq_id'};}

  # store other characteristics of this structral template
    $self->{'name'} = $opts->{'name'} if(defined($opts->{'name'}));
    $self->{'origin'} = $opts->{'origin'} if(defined($opts->{'origin'}));
    $self->{'wt_aa'} = $opts->{'wt_aa'} if(defined($opts->{'wt_aa'}));
    $self->{'var_aa'} = $opts->{'var_aa'} if(defined($opts->{'var_aa'}));
    $self->{'start'} = $opts->{'start'} if(defined($opts->{'start'}));
    $self->{'end'} = $opts->{'end'} if(defined($opts->{'end'}));
    $self->{'ref'} = $opts->{'ref'} if(defined($opts->{'ref'}));
    return( $self );
}


'some true value';
