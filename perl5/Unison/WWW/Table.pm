# U:W:Table -- spit an HTML Table from an array ref of 
package Unison::WWW::Table;

sub render
  {
  my $fr = shift;
  my $ar = shift;
  my $rv = '';
  $rv .= "<table class=\"uwtable\" border=\"0\" width=\"100%\">\n";
  $rv .= "<tr>" . join('',map {'<th align="left">'.$_.'</th>'} @$fr) . "</tr>\n";
  if ($#$ar > -1)
	{ $rv .= "<tr>" . join('',map {'<td>'.$_.'</td>'} @$_) . "</tr>\n" for @$ar; }
  else
	{ $rv .= sprintf("<tr><td colspan=\"%d\">query returned no data</td></tr>\n",$#$fr+1); }
  $rv .= "</table>\n";
  return $rv;
  }

1;
