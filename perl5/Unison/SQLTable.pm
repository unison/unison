# U:W:Table -- spit an HTML Table from an array ref of
package Unison::WWW::Table;
use Unison::Exceptions;
use Data::Dumper;

sub new {
    my $class = shift;
    my $self = bless( {@_}, $class );
    if ( not exists $self->{sth} ) {
        throw Unison::Exception('no statement handle was provided');
    }
    elsif ( exists $self->{cols} and ref $self->{cols} ne 'ARRAY' ) {
        throw Unison::Exception('cols must be defined as an ARRAY');
    }
    print Dumper($self);
    return $self;
}

sub render {
    my $self = shift;

}

############################################################################
## INTERNALS

sub _render_header {
    my $self = shift;
}

1;
