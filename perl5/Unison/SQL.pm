=head1 NAME

Unison::SQL -- Unison pseq table utilities
S<$Id: SQL.pm,v 1.2 2004/02/24 19:23:02 rkh Exp $>

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
use overload '""' => \&sql;


sub new {
  my $class = shift;
  bless({tables => [],
		 columns => [],
		 where => [],
		 order => []
		},$class);
  }


sub columns {
  my $self = shift;
  push( @{$self->{columns}}, @_);
  return $self;
}

sub table { $_[0]->join(splice(@_,1)) }
sub join {
  my $self = shift;
  push( @{$self->{tables}}, @_);
  return $self;
}

sub where {
  my $self = shift;
  push( @{$self->{where}}, @_);
  return $self;
}

sub order {
  my $self = shift;
  push( @{$self->{order}}, @_);
  return $self;
}



sub sql {
  my $self = shift;
  return '' unless @{$self->{columns}};
  CORE::join(' ',
	   'select', CORE::join( ',', @{$self->{columns}} ),
	   (@{$self->{tables}}
		? ' from ' . CORE::join( "   join ", @{$self->{tables}})
		: ''),
	   (@{$self->{where}}
		? ' where ' . CORE::join( '  and  ', @{$self->{where}})
		: ''),
	   (@{$self->{order}}
		? ' order by ' . CORE::join( ',', @{$self->{order}})
		: ''),
	  );
  }




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
