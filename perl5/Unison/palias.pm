=head1 NAME

Unison::palias -- Unison palias table utilities
S<$Id: palias.pm,v 1.13 2004/06/10 22:00:26 rkh Exp $>

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

=head1 DESCRIPTION

B<> is a

=head1 ROUTINES AND METHODS

=cut

package Unison;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use Unison::SQL;
use Unison::Exceptions;


=pod

=head2 B<$u-E<gt>>add_palias_id( C<pseq_id>,C<porigin_id>,C<alias>,C<descr> )>

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




=head2 B<$u-E<gt>>get_pseq_id_from_alias(C<text>)

returns an array of pseq_ids for the given alias by first trying for an
exact match; if that fails, a case-folded search is performed; if that
fails, a fuzzy search (with ilike) is tried.

If the alias starts with /, ~, ~*, or ^, then only the regular express
search is tried.

=back

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
	return(@ids);
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



=head2 B<$u-E<gt>>get_pseq_id_from_alias_exact(C<text>)

returns an array of pseq_ids for exact, case-sensitive matches to the given alias

=back

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


=head2 B<$u-E<gt>>get_pseq_id_from_alias_casefolded(C<text>)

returns an array of pseq_ids for exact, case-INsensitive matches to the given alias

=back

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


=head2 B<$u-E<gt>>get_pseq_id_from_alias_regexp(C<regexp>)

returns an array of pseq_ids by searching for the given alias as a regular
expression.

Regular expression matching may be case sensitive or insensitive, and are
explicitly specified by preceeding the regexp with ~ or ~* respectively.
~ is the default and is optional.

=back

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


=head2 B<$u-E<gt>>get_pseq_id_from_alias_fuzzy(C<text>)

returns an array of pseq_ids by searching for the given alias expression
with ilike.

=back

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