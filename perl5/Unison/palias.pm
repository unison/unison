=head1 NAME

Unison::palias -- Unison palias table utilities
S<$Id: palias.pm,v 1.5 2003/10/18 00:11:03 rkh Exp $>

=head1 SYNOPSIS

use Unison;

my $u = new Unison;

=head1 DESCRIPTION

B<> is a

=head1 ROUTINES AND METHODS

=cut

package Unison;


=pod

=head2 B<$u-E<gt>>add_palias_id( C<pseq_id>,C<porigin_id>,C<alias>,C<descr> )>

adds an alias and description record in the paliasorigin and pseqalias
tables for the existing porigin_id and pseq_id.

=cut

sub add_palias {
  my ($self,$pseq_id,$porigin_id,$alias,$descr) = @_;
  $self->is_open()
	|| croak("Unison connection not established");

  if (defined $descr and $descr =~ /\w/) {
	$descr =~ s/([\'])/\\$1/g;
	$descr =~ s/^\s+//; $descr =~ s/\s+$//; $descr =~ s/\s{2,}/ /;
	$descr = "'$descr'";
  } else {
	$descr = 'NULL'; 
  }

  if ( not defined $pseq_id 
     or not defined $porigin_id
     or not defined $alias 
     or not defined $descr) {
	confess(sprintf("<pseq_id,porigin_id,alias,descr>=<%s,%s,%s,%s>",
					defined $pseq_id ? $pseq_id : 'undef',
					defined $porigin_id ? $porigin_id : 'undef',
					defined $alias ? $alias : 'undef',
					defined $descr ? $descr : 'undef' ));
  }

  $self->do( "insert into palias (pseq_id,porigin_id,alias,descr) "
       . "values ($pseq_id,$porigin_id,'$alias',$descr)",
         { PrintError=>0 } );
  return;
}



### #-------------------------------------------------------------------------------
### # get_pseq_id_from_alias()
### #-------------------------------------------------------------------------------
### 
### =head2 get_pseq_id_from_alias()
### 
###  Name:      get_pseq_id_from_alias()
###  Purpose:   get a pseq_id given an alias
###  Arguments: palias
###  Returns:   array of pseq_id
### 
### =cut
### 
### sub get_pseq_id_from_alias {
###   my ($u,$alias) = @_;
###   $u->is_open() || throw Unison::RuntimeError("Unison connection not established");
###   (defined $alias) 
### 	|| throw Unison::RuntimeError("alias not defined");
###   # this'll be screwed up if the alias contains a ' quote... better to use bind vars...
### 
###   my $sql;
###   my @ids;
### 
###   # case-sensitive first (much faster than case folded search below)
###   $sql = "select distinct pseq_id from palias where alias='$alias'";
###   @ids = @{ $u->{'dbh'}->selectall_arrayref($sql) };
###   return( map {@$_}  @ids ) if @ids;
### 
###   # nothing returned from case-sensitive search -- try case-folding
###   $alias = uc($alias);
###   $sql = "select distinct pseq_id from palias where upper(alias)='$alias'";
###   @ids = @{ $u->{'dbh'}->selectall_arrayref($sql) };
###   return( map {@$_}  @ids );
### }




=head2 B<$u-E<gt>>get_pseq_id_from_alias(C<text>)

returns an array of pseq_ids for the given alias by first trying for an
exact match; if that fails, a case-folded search is performed; if that
fails, a fuzzy search (with ilike) is tried.

If the alias starts with /, ~, ~*, or ^, then only the regular express
search is tried.

=back

=cut

sub get_pseq_id_from_alias {
  my ($u,$alias) = @_;
  $u->is_open() || throw Unison::RuntimeError("Unison connection not established");
  (defined $alias) 
	|| throw Unison::RuntimeError("alias not defined");
  my @ids;

  if ($alias !~ m%^[~/^]%) {				# doesn't smell like a regexp
	(@ids) = $u->get_pseq_id_from_alias_exact( $alias );
	return(@ids) if @ids;

	(@ids) = $u->get_pseq_id_from_alias_casefolded( $alias );
	return(@ids) if @ids;
  }

  if (length($alias) >= 5 or $alias =~ /^[~^]/) {
	(@ids) = $u->get_pseq_id_from_alias_regexp( $alias );
	return(@ids);
  }

  return;
}



=head2 B<$u-E<gt>>get_pseq_id_from_alias_exact(C<text>)

returns an array of pseq_ids for exact, case-sensitive matches to the given alias

=back

=cut

sub get_pseq_id_from_alias_exact {
  my ($u,$alias) = @_;
  $u->is_open() || throw Unison::RuntimeError("Unison connection not established");
  (defined $alias) 
	|| throw Unison::RuntimeError("alias not defined");
  my $sql = 'select distinct pseq_id from palias where alias = ?';
  return( map {@$_} @{ $u->selectall_arrayref($sql, undef, $alias) } );
}


=head2 B<$u-E<gt>>get_pseq_id_from_alias_casefolded(C<text>)

returns an array of pseq_ids for exact, case-INsensitive matches to the given alias

=back

=cut

sub get_pseq_id_from_alias_casefolded {
  my ($u,$alias) = @_;
  $u->is_open() || throw Unison::RuntimeError("Unison connection not established");
  (defined $alias) 
	|| throw Unison::RuntimeError("alias not defined");
  my $sql = 'select distinct pseq_id from palias where upper(alias) = ?';
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
  my ($u,$alias) = @_;
  $u->is_open() || throw Unison::RuntimeError("Unison connection not established");
  (defined $alias)
	|| throw Unison::RuntimeError("alias not defined");
  my $op = $alias =~ s/^(~\*?)//g ? $1 : '~';
  #$alias =~ s%^/(.+)/$%$1%;					# remove // from /<regexp>/
  my $sql = 'select distinct pseq_id from palias where ';
  if ($op eq '~') {
	$sql .= 'alias ~ ?';
  } else {
	$sql .= 'upper(alias) ~ ?';
	$alias = uc($alias);
  }
  return( map {@$_} @{ $u->selectall_arrayref($sql, undef, $alias) } );
}


=head2 B<$u-E<gt>>get_pseq_id_from_alias_fuzzy(C<text>)

returns an array of pseq_ids by searching for the given alias expression
with ilike.

=back

=cut

sub get_pseq_id_from_alias_fuzzy {
  my ($u,$alias) = @_;
  $u->is_open() || throw Unison::RuntimeError("Unison connection not established");
  (defined $alias) 
	|| throw Unison::RuntimeError("alias not defined");
  #my $sth = $u->prepare($sql);
  #$sth->execute($alias);
  my $sql = 'select distinct pseq_id from palias where alias ilike ?';
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
