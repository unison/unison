# Unison::Utilities::links -- build HTML links for various database content

package Unison;

use strict;
use warnings;

use Unison;
#push(@EXPORT_OK, qw( origin_alias_link ) );

use Unison::Exceptions;


sub _fetch_formats($);

my %origin_link_fmt;


sub origin_alias_url($$$) {
  my ($u,$o,$a) = @_;
  if (not %origin_link_fmt) {
	$u->_fetch_formats();
  }
  if (not exists $origin_link_fmt{$o}) {
	throw Unison::Exception( "Origin `$o' is not valid." );
  }
  if (not defined $origin_link_fmt{$o}->{link_url}) {
	throw Unison::Exception( "Origin `$o' is valid but doesn't have a link URL defined." );
  }
  return sprintf($origin_link_fmt{$o}->{link_url}, $a);
}




sub _fetch_formats($) {
  my ($u) = @_;
  (%origin_link_fmt) = %{ $u->selectall_hashref('select origin,link_url from porigin','origin') };
  return;
}

1;

