# U:W:Table -- spit an HTML Table from an array ref of 
package Unison::WWW::Table;

use base 'CBT::Hash';


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
  my $fr = shift;
  my $ar = shift;
  my $opts = shift;
  my $rv = '';

  $rv .= "<table class=\"uwtable\" border=\"0\" width=\"100%\">\n";
  if ($#$ar > -1) {
	if (defined $opts->{highlight_column}) {
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
		  $rv .= "<td $cl $al>$row[$c]</td>";
		}
		$rv .= "</tr>\n";
	  }
	} else {
	  $rv .= "<tr>" . join('',map {'<th align="'.guess_alignment($_).'">'.$_.'</th>'} @$fr)."</tr>\n";
	  $rv .= "<tr>" . join('',map {'<td>'.$_.'</td>'} @$_) . "</tr>\n" for @$ar; 
	}
  } else {
	$rv .= sprintf("<tr><td bgcolor=\"$highlight_color\" colspan=\"%d\">query returned no data</td></tr>\n",$#$fr+1);
  }
  $rv .= "</table>\n";
  return $rv;
}

sub guess_alignment {
  my $s = shift;
  return $s =~ m/[^-.\d]/ ? 'left' : 'right';
  }


1;
