=head1 NAME

CBT::Hash -- Hash record superclass

S<$Id: Hash.pm,v 0.8 2001/06/07 06:20:00 reece Exp $>

=head1 SYNOPSIS

C<tflush [time]>

=head1 DESCRIPTION

B<CBT::Hash> provides some rudimentary facilities useful for manipulating
hashes.

=cut


package CBT::Hash;
BEGIN{
use CBT::debug;
our $VERSION = CBT::debug::RCSVersion( '$Revision$ ' );
CBT::debug::identify_file() if ($CBT::debug::trace_uses);
}

use strict;
use warnings;
use base 'CBT::Root';
use overload '""' => \&stringify;

sub new
  {
  my $type = shift;
  my $self = @_ ? initialize(@_) : {};
  return( bless($self, $type) );
  }

sub initialize
  {
  my $self = shift;
  if (ref $_[0])							# new blah ( {-text=>blah, -advice=>soakhead, ...} )
	{ %$self = %{$_[0]}; }
  elsif ( $_[0] =~ m/^-/ )					# new blah ( -text=>blah, -advice=>soakhead, ... )
	{ %$self = @_; }
  return $self;
  }

sub stringify
  {
  my $self = shift;
  my $t = (ref $self) . " contains:\n";
  foreach my $k (sort keys %{$self})
	{ $t .= $k . ' = ' . ( defined $self->{$k} ? $self->{$k} : '(undef)' ) ."\n"; }
  return($t);
  }


sub _getset
  {
  my $self = shift;
  my $iv = shift;
  return( @_ ? $self->{$iv} = shift : $self->{$iv} );
  }

sub AUTOLOAD
  {
  my $self = shift;
  use vars qw/$AUTOLOAD/;
  return if $AUTOLOAD =~ /::DESTROY$/;		# don't propagate DESTROY messages
  dprint(4,"autoloading $AUTOLOAD");
  my $tag; ($tag = $AUTOLOAD) =~ s/.*:://;
  # return( $self->_getset($tag, @_) );
  # code function on the fly; tag is a valid (nonexistant) method name
  my $code = "sub $tag { my \$self = shift; \@_ ? \$self->{$tag} = shift : \$self->{$tag}; }";
  eval $code;
  return( $self->$tag(@_) );
  }



=pod

=head1 INSTALLATION

Put this file in your perl lib directory (usually /usr/local/perl5/lib) or
one of the directories in B<$PERL5LIB>.

@@banner@@

=cut

1;
