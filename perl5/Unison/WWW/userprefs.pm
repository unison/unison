package Unison;
use strict;
use warnings;


# return user prefs as hashref
sub get_userprefs {
  my $self = shift;
  my $userprefs;
  $self->is_open()
	|| croak("Unison connection not established");

  my $sth = $self->prepare('select userprefs.* from userprefs  natural join pg_user where usename=?');

  # try for this user
  $userprefs = $self->selectrow_hashref($sth,undef,$self->{username});

  # else use PUBLIC user's prefs
  if (not defined $userprefs) {
	$userprefs = $self->selectrow_hashref($sth,undef,'PUBLIC');
  }

  # ack! at least return a reasonable guess
  if (not defined $userprefs) {
	$userprefs = { show_sql => 1,
				   show_tips => 1
				 };
  }

  return $userprefs;
  }


1;
