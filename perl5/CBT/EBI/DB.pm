##############################################################################
## Nothing to modify beyond this line
##############################################################################

=head1 NAME

Prosite::DB -- Prosite DB access

S<$Id: DB.pm,v 0.3 1999/06/06 21:47:01 reece Exp $>

=head1 SYNOPSIS

C<tflush [time]>

=head1 DESCRIPTION

B<tflush> 

=head1 INSTALLATION

Put this file in your perl lib directory (usually /usr/local/perl5/lib) or
one of the directories in B<$PERL5LIB>.

@@banner@@

=cut

##############################################################################
## Nothing to modify beyond this line
##############################################################################

BEGIN {
    $RCSHeader =
'$Header: /mnt/cvs/cbc/opt/lib/perl5/EBI/DB.pm,v 0.3 1999/06/06 21:47:01 reece Exp $ ';
    print("# $RCSHeader\n") if ( defined $main::DEBUG and $main::DEBUG );
}

package CBT::EBI::DB;
use IO::File;

@ISA = qw(IO::File);

sub open {
    my ( $self, $fn ) = @_;
    $self->SUPER::open("<$fn")
      || return (undef);
    $self->read_idx($fn)
      || do { $self->scan; $self->write_idx($fn); };
    return ($self);
}

sub write_idx {
    my ( $self, $fn ) = @_;
    my ($ofn) = "$fn.idx";
    if ( -f $ofn and not -w $ofn ) {
        warn("$ofn exists but isn't writable; index not rewritten\n");
        return (0);
    }
    my ($ofh) = new IO::File;
    $ofh->open(">$ofn")
      || do { warn("$ofn: $!\n"); return (0); };
    print( STDERR "# writing $ofn\n" );
    foreach $key ( $self->keys ) {
        $ofh->printf( "%d\0%s\0\0", $self{pos}{$key}, $key );
    }
    $ofh->close;
    return (1);
}

sub read_idx {
    my ( $self, $fn ) = @_;
    my ($ifn) = "$fn.idx";
    if ( -r $ifn ) {
        if ( ( stat($fn) )[9] > ( stat($ifn) )[9] ) {
            warn("$ifn older than $fn; ignoring obsolete index $ifn\n");
            return (0);
        }
        my ($ifh) = new IO::File;
        $ifh->open($ifn);
        print( STDERR "# reading $ifn\n" );
        local ($/) = "\0\0";
        while (<$ifh>) {
            my ( $pos, $key );
            ( $pos, $key ) = split(/\0/);
            $self{pos}{$key} = $pos;
        }
        $ifh->close;
        return (1);
    }
    print( STDERR "# $ifn doesn't exist\n" );
    return (0);
}

sub record_delimiter { "\n//\n"; }

sub scan {
    my ($self) = shift;
    my ($pos)  = 0;
    local ($/) = $self->record_delimiter;
    print( STDERR "# building index\n" );
    $self->seek( 0, SEEK_SET );
    while (<$self>) {
        if (/^ID\s+([^\s;]+)/m) { $self{pos}{$1} = $pos; }
        if (/^AC\s+([^\s;]+)/m) { $self{pos}{$1} = $pos; }
        $pos = $self->tell();
    }
}

sub read_record {
    my ( $self, $r ) = @_;
    my ($pos) = $self{'pos'}{$r};
    if ( defined $pos ) {
        $self->seek( $pos, SEEK_SET )
          || do { warn("$!\n"); return (undef); };
        local ($/) = $self->record_delimiter;
        $_ = $self->getline;
        chomp;
        return ($_);
    }
    warn("Attempt to read non-existant record $r from database.\n");
    return (undef);
}

sub keys {
    my ($self) = @_;
    return ( keys %{ $self{pos} } );
}

1;
