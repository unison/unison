=head1 NAME

Unison::SQL -- Unison pseq table utilities
S<$Id: pseq.pm,v 1.4 2003/06/11 00:15:16 cavs Exp $>

=head1 SYNOPSIS

use Unison::SQL;

my $u = new Unison::SQL;

(etc.)

=head1 DESCRIPTION

B<> is a

=head1 ROUTINES AND METHODS

=cut

package Unison::SQL;
use overload '""' => \&sql;


sub new {
  my $class = shift;
  bless({tables => [],
		 columns => [],
		 where => []
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

sub sql {
  my $self = shift;
  return '' unless @{$self->{columns}};
  join(' ',
	   'select', join( ',', @{$self->{columns}} ),
	   (@{$self->{tables}}
		? ' from ' . join( "   join ", @{$self->{tables}})
		: ''),
	   (@{$self->{where}}
		? ' where ' . join( '  and  ', @{$self->{where}}) 
		: '')
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
