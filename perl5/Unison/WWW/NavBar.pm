package Unison::WWW::NavBar;


sub render
  {
  my @lr = shift;							# link ref [[name,url],...]
  my $hilight = shift;						# which to highlight
  my $rv = "<table class=\"navbar\"><tr>";
  for( my $i=0; $i<=$#$lr; $i++ )
	{
	my $c = 
	$rv .= sprintf('<td%s><a href="%s">%s</a></td>',
				   ($i == $hilight-1) ? ' class="hi"' : '',
				   @{$lr->[$i]}[1,0]);
	}
  $rv .= '</tr></table>';
  return $rv;
  }

1;
