package Unison::WWW::utils;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;
use base 'Exporter';
our @EXPORT_OK = qw
  (pseq_summary_link alias_link alias_gglink alias_splink alias_reflink text_wrap coalesce );
our @EXPORT = ();

use Text::Wrap;


sub alias_link {
  my ($alias,$origin) = @_;
  if ($origin eq 'SPDI') {
	return( alias_gglink($alias) );
  } elsif ($origin eq 'Swiss-Prot') {
	return( alias_splink($alias) ) 
  } elsif ($origin eq 'Ensembl') {
	return( alias_enslink($alias) )
  } elsif ($alias =~ m/^[XN]P/) {
	return( alias_reflink($alias) )
  } else {
	return( $_[0] );
  }
}

sub pseq_summary_link {
  my ($pseq_id,$tag) = @_;
	return( "<a href=\"pseq_summary.pl?pseq_id=$pseq_id\">$tag</a>" );
}


sub alias_gglink {
  $_[0] =~ s%^(UNQ|PRO|DNA)(\d+)$%<a href="http://research/projects/gg/jsp/$1.jsp?$1ID=$2">$&</a>%;
  $_[0];
  }

sub alias_splink {
  "<a href=\"http://us.expasy.org/cgi-bin/niceprot.pl?$_[0]\">$_[0]</a>";
  }

sub alias_reflink {
  "<a href=\"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Search&db=Protein&term=$_[0]\">$_[0]</a>";
  }

sub alias_enslink {
  "<a href=\"http://www.ensembl.org/Homo_sapiens/textview?species=All&idx=Protein&q=$_[0]\">$_[0]</a>";
  }

sub text_wrap {
  #local $Text::Wrap::break = qr/\s|(?:[,=])/;
  local $Text::Wrap::unexapand = 0;
  return Text::Wrap::wrap('','', map {s/,/, /g;$_} grep { defined } @_);
  }

sub coalesce {
  # return first not null element of args, or undef
  # à la SQL's coalesce
  while (@_ and not defined $_[0]) {
	shift; }
  return $_[0];								# may be undef if list exhausted
  }

1;
