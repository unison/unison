package Base::Record;
use strict;
use warnings;

our ($VERSION) = q$Revision: 1.2 $ =~ m/Revision: ([\d\.]+)/;

use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use fields qw( );
use Base::Misc qw( iprint );
use vars qw(@ISA @EXPORT @EXPORT_OK);
use Carp;
use Data::Dumper;

## public methods:
sub new
  {
  my $self = shift;							# class name or ref
  if (not ref $self)						# if class name, then setup
	{ $self = fields::new($self); }			#    fields (create pseudohash)
  $self->stuff(@_);							# init members
  return $self;
  }

# template new for subclasses WHICH REQUIRE SPECIAL INITIALIZATION
# (otherwise, just inherit the one above)
# sub new
# 	{
# 	my $self = shift;
# 	$self = fields::new($self) unless ref $self;
# 	$self->SUPER::new(@_);
# 	return $self;
# 	}


sub stuff
  # init $self from hash elements
  {
  my $self = shift;
  my %hr = @_;
  foreach my $k (keys %hr)
	{ 
	#print "$k: $hr{$k}\n"; 
	$self->{$k} = $hr{$k};
	}
  return $self;
  }

sub dump
  {
  my $self = shift;
  Data::Dumper->new([$self])->Indent(0)->Terse(1)->Dump();
  }


use overload '""' => \&stringify;
sub stringify
  { 
  my $self = shift;
  my $t = (ref $self) . " contains:\n";
  foreach my $k (sort keys %{$self})
	{ $t .= $k . ' = ' . ( defined $self->{$k} ? $self->{$k} : '(undef)' ) ."\n"; }
  return($t);
  }



## private methods:
sub _getset
  {
  my $self = shift;
  my $iv = shift;
  return( @_ ? $self->{$iv} = shift : $self->{$iv} );
  }

sub AUTOLOAD
  {
  my $self = shift;
  our $AUTOLOAD;
  my $tag; ($tag = $AUTOLOAD) =~ s/.*:://;
  return if ($tag eq 'DESTROY');
  if (not exists $self->[0]{$tag})
	{ croak("$tag is not a valid field; cannot create autoloaded access method\n"); }
  iprint(4,"autoloading $AUTOLOAD ($tag)");
  # Handle the get/set ourselves:
  #   return( $self->_getset($tag, @_) );
  # or, better, code function on the fly and eval it:
  my $code = "sub $tag { my \$self = shift; \@_ ? \$self->{$tag} = shift : \$self->{$tag}; }";
  eval $code;
  return( $self->$tag(@_) );
  }

1;
