#!/usr/bin/env perl

print("<html><body>\n",
	  "<hr>\n",
	  imgs(undef,@ARGV),
	  "<hr>\n",
	  imgs('grey',@ARGV),
	  "<hr>\n",
	  imgs('yellow',@ARGV),
	  "</body></html>\n");


sub imgs
  {
  my $c = shift;
  $c = " bgcolor=\"$c\"" if defined $c;
  return( "<table width=\"100%\"><tr><td$c>\n",
		  (map { "<br>$_ <img src=\"$_\">\n" } @_),
		  "</td></tr></table>\n");
  }
