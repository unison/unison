package Unison::WWW::Utils;
use base 'Exporter';
@EXPORT_OK = qw( alias_link alias_gglink alias_splink alias_reflink );
@EXPORT = ();


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


1;
