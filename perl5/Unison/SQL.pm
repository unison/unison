=head1 NAME

Unison::SQL -- Unison pseq table utilities
S<$Id: SQL.pm,v 1.3 2004/05/04 04:46:33 rkh Exp $>

=head1 SYNOPSIS

use Unison::SQL;

my $u = new Unison::SQL;

(etc.)

=head1 DESCRIPTION

B<> is a

=head1 ROUTINES AND METHODS

=cut

package Unison::SQL;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;
use overload '""' => \&stringify;
use Unison::Exceptions;


sub new {
  my $class = shift;
  bless({tables => [],
		 distinct => [],
		 columns => [],
		 where => [],
		 order => [],
		 offset => undef,
		 limit => undef,
		},$class);
  }


sub columns {
  my $self = shift;
  if (@_) {
	if (defined $_[0]) {
	  push( @{$self->{columns}}, @_);
	} else {
	  $self->{columns} = [];
	}
  }
  return $self;
}

sub distinct {
  my $self = shift;
  if (@_) {
	if (defined $_[0]) {
	  push( @{$self->{distinct}}, @_);
	} else {
	  $self->{distinct} = [];
	}
  }
  return $self;
}

sub table { $_[0]->join(splice(@_,1)) }
sub join {
  my $self = shift;
  if (@_) {
	if (defined $_[0]) {
	  push( @{$self->{tables}}, @_);
	} else {
	  $self->{tables} = [];
	}
  }
  return $self;
}

sub where {
  my $self = shift;
  if (@_) {
	if (defined $_[0]) {
	  push( @{$self->{where}}, @_);
	} else {
	  $self->{where} = [];
	}
  }
  return $self;
}

sub order {
  my $self = shift;
  if (@_) {
	if (defined $_[0]) {
	  push( @{$self->{order}}, @_);
	} else {
	  $self->{order} = [];
	}
  }
  return $self;
}

sub limit {
  my $self = shift;
  $self->{limit} = $_[0];
  return $self;
}

sub offset {
  my $self = shift;
  $self->{offset} = $_[0];
  return $self;
}


sub sql {
  my $self = shift;

  (@{$self->{columns}})
	|| throw Unison::Exception::RuntimeError('Nothing selected in Unison::SQL object');

  my @sql = 'SELECT';
  push(@sql, 'DISTINCT ON', '(', CORE::join( ',', @{$self->{distinct}}), ')') if @{$self->{distinct}};
  push(@sql, CORE::join( ',', @{$self->{columns}} ) );
  push(@sql, 'FROM', CORE::join( "   JOIN ", @{$self->{tables}})) if @{$self->{tables}};
  push(@sql, 'WHERE', CORE::join( '  AND  ', @{$self->{where}})) if @{$self->{where}};
  push(@sql, 'ORDER BY', CORE::join( ',', @{$self->{order}})) if @{$self->{order}};
  push(@sql, 'OFFSET', $self->{offset}) if defined $self->{offset};
  push(@sql, 'LIMIT', $self->{limit}) if defined $self->{limit};

  wantarray ? @sql : CORE::join(' ', @sql);
}

sub stringify { scalar($_[0]->sql()) }



=pod

=head1 BUGS

=head1 SEE ALSO

=head1 AUTHOR

 Reece Hart, Ph.D.                     rkh@gene.com, http://www.gene.com/
 Genentech, Inc.                       650/225-6133 (voice), -5389 (fax)
 Bioinformatics Department             
 1 DNA Way, MS-93                      http://www.in-machina.com/~reece/
 South San Francisco, CA  94080-4990   reece@in-machina.com, GPG: 0x25EC91A0

=cut

1;
