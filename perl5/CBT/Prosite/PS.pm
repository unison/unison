=head1 NAME

Prosite.pm -- Prosite Pattern and Profile Manipulation in Perl

S<$Id: PS.pm,v 0.4 1999/06/06 21:47:21 reece Exp $>

=head1 SYNOPSIS

C<use Prosite>

=head1 DESCRIPTION

B<Prosite> 

=head1 INSTALLATION

@@banner@@

=cut

##############################################################################
## Nothing to modify beyond this line
##############################################################################

BEGIN
  {
  $RCSHeader = '$Header: /mnt/cvs/cbc/opt/lib/perl5/Prosite/PS.pm,v 0.4 1999/06/06 21:47:21 reece Exp $ ';
  print("# $RCSHeader\n") if (defined $main::DEBUG and $main::DEBUG);
  }

package Prosite;
use Prosite::DB;

@linecode = qw( ID, AC, DT, DE, PA, MA, RU, NR, CC, DR, 3D, DO )
$linecode_re = join('|',@linecode);
for($i=0;$i<=$@linecodes;$i++)
  {
  eval "\$$linecode[$i] = $i";
  $linecode{$linecode[$i]} = $i;
  };



__END__

	if ( (m%/PARTIAL=(\d+)%)
		 and ($1 != 0) )					# non-zero partials
	  {
	  my($npartials) = $1;					# number of partials
	  my(@partials);
	  my($AC) = m/^AC\s+(\w+)/m;			# AC for this block
	  die("AC not found:\n$_\n ") unless defined $AC;
	  $AC = uc($AC);
	  while(m/[A-Z]\d{5},\s*([^, \t]+)\s*,\s*P/g)
		{ push(@partials,$1); }
	  (1+$#partials == $npartials)
		|| die("expected $npartials partials, got ", 1+$#partials, "\n$_\n ");
	  $partials{$AC} = join('|',@partials);




  ID   RNA_POL_N_8KD; PATTERN.
AC   PS01112;
DT   NOV-1995 (CREATED); NOV-1997 (DATA UPDATE); JUL-1998 (INF UPDATE).
DE   RNA polymerases N / 8 Kd subunits signature.
PA   [LIVMF](2)-P-[LIVM]-x-C-F-[ST]-C-G.
NR   /RELEASE=36,74019;
NR   /TOTAL=8(8); /POSITIVE=8(8); /UNKNOWN=0(0); /FALSE_POS=0(0);
NR   /FALSE_NEG=0; /PARTIAL=0;
CC   /TAXO-RANGE=A?E?V; /MAX-REPEAT=1;
DR   P42488, RPBX_ASFB7, T; Q39290, RPBX_BRANA, T; P52436, RPBX_HUMAN, T;
DR   O13877, RPBX_SCHPO, T; P22139, RPBX_YEAST, T; P29199, RPON_HALMA, T;
DR   Q57649, RPON_METJA, T; P39472, RPON_SULAC, T;
DO   PDOC00856;

  }
