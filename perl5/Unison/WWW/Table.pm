# U:W:Table -- spit an HTML Table from an array ref of 
package Unison::WWW::Table;
use strict;
use warnings;

use base 'CBT::Hash';
use Unison::WWW::utils;


# title
# caption
# cols = @<cols>
# row_fmt (_fx?) [ <tr> %s </tr> ]
# row_alt_color [rgb1,rgb2]
# class
# col_url
#
# col:=
# heading
# url
# tooltip
# cell_format => &(data), %s
# justification
# width
# cell_preprocess


sub render {
  return render_compat(@_) unless (ref $_[0] eq __PACKAGE__);

  # BELOW THIS POINT IS EXPERIMENTAL
  my $self = shift;
  my $fr = shift;
  my $rv = '';
  $rv .= "<table class=\"uwtable\" border=\"0\" width=\"100%\">\n";
  $rv .= "<tr>" . join('',map {'<th align="left">'.$_.'</th>'} @$fr) . "</tr>\n";
  foreach(my $i; $i<=$#_; $i++) {
  }
  $rv .= "</table>\n";
  return($rv);
}

sub render_headings {
  my $self = shift;
  return join( '', '<tr>', map { __render_th($_) } @{$self->{columns}}, '</tr>' );
  }
sub render_th {
  return '<th>';
}



sub render_compat {
  # this code is among the worst I've written. I'm sorry.

  my $fr = shift;
  my $ar = shift;
  my $opts = shift;

  my $tbl_start = "<table class=\"uwtable\" border=\"0\" width=\"100%\">\n";
  my $tbl_end = "</table>\n";

  my $rv = $tbl_start;

  if ($#$ar == -1) {
	$rv .= sprintf("<tr><td colspan=\"%d\">query returned no data</td></tr>\n",$#$fr+1);
	$rv .= $tbl_end;
	return $rv;
  }

  if (not defined $opts->{highlight_column}) {
	$rv .= "<tr>" . join('',map {'<th align="'.guess_alignment($_).'">'.$_.'</th>'} @$fr)."</tr>\n";
	$rv .= "<tr>" . join('',map {'<td ailgn="'.guess_alignment($_).'">'.Unison::WWW::utils::coalesce($_,'').'</td>'} @$_) ."</tr>\n" for @$ar; 
	$rv .= $tbl_end;
	return $rv;
  }

  # remainder is for the special case of column highlighting
  $rv .= '<tr>' . join('', map { '<th'
								   . ($_==$opts->{highlight_column} ? ' class="highlighted"' : '').'>'
									 . $fr->[$_] .'</th>'
								   }
					   0..$#$fr) . "</tr>\n";
  for(my $r=0; $r<=$#$ar; $r++) {
	$rv .= "<tr>";
	my @row = @{ $ar->[$r] };
	for(my $c=0; $c<=$#row; $c++) {
	  my $cl = $c==$opts->{highlight_column} ? 'class="highlighted"' : '';
	  my $al = 'align="' . guess_alignment($row[$c]) . '"';
	  $rv .= "<td $cl $al>" . Unison::WWW::utils::coalesce($row[$c],'') . "</td>";
	}
	$rv .= "</tr>\n";
  }

  $rv .= $tbl_end;
  return $rv;
}


sub guess_alignment {
  my $s = shift;
  return (defined $s and $s =~ m/^[-.e\d]+$/) ? 'right' : 'left';
  }


1;
