=head1 NAME

Unison::palias -- Unison palias table utilities
S<$Id: palias.pm,v 1.16 2005/01/20 01:05:17 rkh Exp $>

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

=head1 DESCRIPTION

In Unison, each distinct sequence may derive from one or more databases
(origins) and be associated with zero or more names (aliases) from those
databases. This module provides an interface to the alias and origin data
for Unison sequences.

=cut

package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use Unison::Exceptions;


=pod

=head1 ROUTINES AND METHODS

=over

=cut


######################################################################
## add_palias_id( )

=pod

=item B<< $u->add_palias_id( C<pseq_id>,C<porigin_id>,C<alias>,C<descr> ) >>

adds an alias and description record in the paliasorigin and pseqalias
tables for the existing porigin_id and pseq_id.

=cut

sub add_palias {
  my ($self,$pseq_id,$porigin_id,$alias,$descr,$tax_id) = @_;
  $self->is_open()
	|| croak("Unison connection not established");

  if (defined $descr and $descr =~ /\w/) {
    $descr =~ s/([\'])/\\$1/g;
    $descr =~ s/^\s+//; $descr =~ s/\s+$//; $descr =~ s/\s{2,}/ /;
    $descr = "'$descr'";
  } else {
    $descr = 'NULL';
  }

  $tax_id = ( defined $tax_id ) ? $tax_id : 'NULL';

  if ( not defined $pseq_id 
	   or not defined $porigin_id
	   or not defined $alias 
	   or not defined $descr) {
	die("Assertion failed\n",
		sprintf("<pseq_id,porigin_id,alias,descr>=<%s,%s,%s,%s>",
				defined $pseq_id ? $pseq_id : 'undef',
				defined $porigin_id ? $porigin_id : 'undef',
				defined $alias ? $alias : 'undef',
				defined $descr ? $descr : 'undef' )
	   );
  }

  my $sql = "insert into palias (pseq_id,porigin_id,alias,descr,tax_id) "
	. "values ($pseq_id,$porigin_id,'$alias',$descr,$tax_id)";
  print STDERR "sql: $sql\n" if $ENV{DEBUG};
  $self->do( $sql, { PrintError=>1 } );
  return;
}




######################################################################
## get_pseq_id_from_alias( )

=pod

=item B<< $u->get_pseq_id_from_alias(C<text>) >>

returns an array of distinct pseq_ids for the given alias by first trying
for an exact match; if that fails, a case-folded search is performed; if
that fails, a fuzzy search (with ilike) is tried.

If the alias starts with /, ~, ~*, or ^, then only the regular express
search is tried.

=cut

sub get_pseq_id_from_alias {
  my ($u,$alias,$ori) = @_;
  $u->is_open()
	|| throw Unison::RuntimeError("Unison connection not established");
  (defined $alias)
	|| throw Unison::RuntimeError("alias not defined");
  my @ids;

  # Genentech-only: if it looks like an Genentech UNQ, DNA, or PRO, 
  # do that search only.
  ## THIS DOESN'T BELONG HERE, BUT IT'S USEFUL.
  if ($alias =~ m%^(UNQ|DNA|PRO|FAM)(\d+)$%i) {
	my ($type,$id) = (uc($1),$2);
	my $sql;

	if ($type eq 'PRO' or $type eq 'DNA' or $type eq 'UNQ') {
	  $sql = sprintf('select distinct pseq_id from sst.v_sst_unison where %sID=%d',
					 $type,$id);
	} elsif ($type eq 'FAM') {
	  $sql = sprintf('select distinct pseq_id from sst.v_fam_pseq where %sID=%d',
					 $type,$id);
	} else {
	  throw Unison::Exception('Unmatched SST entry type',
							  "I don't know what a $type entry is");
	};

	(@ids) = map {@$_} @{ $u->selectall_arrayref($sql) };
	return(@ids) if @ids;					# some ids might have been removed from sst; in that
											# case, @ids will be empty and we'll continue with an
											# alias lookup below
  }

  if (not $alias =~ m%^[~/^]%) {
	# doesn't smell like a regexp

	(@ids) = $u->get_pseq_id_from_alias_casefolded( $alias,$ori );
	return(@ids) if @ids;

	if ($alias =~ m/^[NXZAY]P_\d+$/) {
	  # looks like an unversioned RefSeq alias; official protein sequence
	  # prefixes are listed in
	  # ftp://ftp.ncbi.nih.gov/refseq/release/release-notes/RefSeq-release4.txt
	  # and http://www.ncbi.nih.gov/RefSeq/key.html#accessions
	  (@ids) = $u->get_pseq_id_from_alias_regexp( "^$alias",'RefSeq' );
	  return(@ids) if @ids;
	}
  }

  if (length($alias) >= 5 or $alias =~ /^[~^]/) {
	# looks like a regexp OR exact match above failed
	(@ids) = $u->get_pseq_id_from_alias_regexp( $alias,$ori );
	return(@ids);
  }

  return;
}



######################################################################
## get_pseq_id_from_alias_exact( )

=pod

=item B<< $u->get_pseq_id_from_alias_exact(C<text>) >>

returns an array of distinct pseq_ids for exact, case-sensitive matches to
the given alias

=cut

sub get_pseq_id_from_alias_exact {
  my ($u,$alias,$ori) = @_;
  $u->is_open()
	|| throw Unison::RuntimeError("Unison connection not established");
  (defined $alias) 
	|| throw Unison::RuntimeError("alias not defined");
  my $sql = 'select distinct pseq_id from palias where alias = ?';
  $sql .= " AND porigin_id=porigin_id('$ori')" if defined $ori;
  return( map {@$_} @{ $u->selectall_arrayref($sql, undef, $alias) } );
}


######################################################################
## get_pseq_id_from_alias_casefolded( )

=pod

=item B<< $u->get_pseq_id_from_alias_casefolded(C<text>) >>

returns an array of distinct pseq_ids for exact, case-INsensitive matches
to the given alias

=cut

sub get_pseq_id_from_alias_casefolded {
  my ($u,$alias,$ori) = @_;
  $u->is_open()
	|| throw Unison::RuntimeError("Unison connection not established");
  (defined $alias) 
	|| throw Unison::RuntimeError("alias not defined");
  my $sql = 'select distinct pseq_id from palias where upper(alias) = ?';
  $sql .= " AND porigin_id=porigin_id('$ori')" if defined $ori;
  return( map {@$_} @{ $u->selectall_arrayref($sql, undef, uc($alias)) } );
}


######################################################################
## get_pseq_id_from_alias_regexp( )

=pod

=item B<< $u->get_pseq_id_from_alias_regexp(C<regexp>) >>

returns an array of distinct pseq_ids by searching for the given alias as
a regular expression.

Regular expression matching may be case sensitive or insensitive, and are
explicitly specified by preceeding the regexp with ~ or ~* respectively.
~ is the default and is optional.

=cut

sub get_pseq_id_from_alias_regexp {
  my ($u,$alias,$ori) = @_;
  $u->is_open() 
	|| throw Unison::RuntimeError("Unison connection not established");
  (defined $alias)
	|| throw Unison::RuntimeError("alias not defined");
  my $op = $alias =~ s/^(~\*?)//g ? $1 : '~';
  #$alias =~ s%^/(.+)/$%$1%;          # remove // from /<regexp>/
  my $sql = 'select distinct pseq_id from palias where ';
  if ($op eq '~') {
	$sql .= 'alias ~ ?';
  } else {
	$sql .= 'upper(alias) ~ ?';
	$alias = uc($alias);
  }
  $sql .= " AND porigin_id=porigin_id('$ori')" if defined $ori;
  return( map {@$_} @{ $u->selectall_arrayref($sql, undef, $alias) } );
}


######################################################################
## get_pseq_id_from_alias_fuzzy( )

=pod

=item B<< $u->get_pseq_id_from_alias_fuzzy(C<text>) >>

returns an array of distinct pseq_ids by searching for the given alias
expression with ilike.

=cut

sub get_pseq_id_from_alias_fuzzy {
  my ($u,$alias,$ori) = @_;
  $u->is_open()
	|| throw Unison::RuntimeError("Unison connection not established");
  (defined $alias) 
	|| throw Unison::RuntimeError("alias not defined");
  my $sql = 'select distinct pseq_id from palias where alias ilike ?';
  $sql .= " AND porigin_id=porigin_id('$ori')" if defined $ori;
  return( map {@$_} @{ $u->selectall_arrayref($sql, undef, $alias) } );
}






=pod

=back

=head1 BUGS

Please report bugs to Reece Hart E<lt>hart.reece@gene.comE<gt>.

=head1 SEE ALSO

=over 4

=item * perldoc Unison

=back

=head1 AUTHOR

see C<perldoc Unison> for contact information

=cut

1;
