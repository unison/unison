# Unison::Utilities::links -- build HTML links for various database content

package Unison;

use strict;
use warnings;

use Unison;

#push(@EXPORT_OK, qw( origin_alias_link ) );

use Unison::Exceptions;

sub _fetch_formats($);

my %origin_link_fmt;

sub link_url($$$) {
    my ( $u, $o, $a ) = @_;
    my $sth = $u->prepare_cached('select link_url(?,?)');
    return $u->selectrow_array( $sth, undef, $o, $a );
}

sub origin_accession_url($$$) {
    my ( $u, $o, $a ) = @_;
    if ( not %origin_link_fmt ) {
        $u->_fetch_formats();
    }
    if ( not exists $origin_link_fmt{$o} ) {
        throw Unison::Exception("Origin `$o' is not valid.");
    }
    if ( not defined $origin_link_fmt{$o}->{link_url} ) {
        throw Unison::Exception(
            "Origin `$o' is valid but doesn't have a link URL defined.");
    }
    return sprintf( $origin_link_fmt{$o}->{link_url}, $a );
}

sub _fetch_formats($) {
    my ($u) = @_;
    return if %origin_link_fmt;
    %origin_link_fmt =
      %{ $u->selectall_hashref( 'select origin,link_url from origin', 'origin' )
      };
    return;
}

1;

