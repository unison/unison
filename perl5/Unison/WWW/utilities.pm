package Unison::WWW::utilities;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;
use base 'Exporter';
our @EXPORT_OK = qw
  (pseq_summary_link alias_link alias_gglink alias_splink alias_reflink text_wrap coalesce );
our @EXPORT = ();

use Text::Wrap;

#### NOTE:
#### The URL formats /should/ come from the origin table (origin.url)
#### using Unison::links.  However, those need a Unison ref and these
#### functions don't provide such.

sub alias_link {
    my ( $alias, $origin ) = @_;
    if ( $origin eq 'GenenGenes' ) {
        return ( alias_gglink($alias) );
    }
    elsif ( $origin eq 'Swiss-Prot' ) {
        return ( alias_splink($alias) );
    }
    elsif ( $origin =~ m/^uniprot/i ) {
        return ( alias_uniprot_link($alias) );
    }
    elsif ( $origin eq 'Ensembl' ) {
        return ( alias_enslink($alias) )

          # diabling the url. //research/products/proteome does not work
          #  } elsif ($origin eq 'Proteome') {
          #	return( alias_proteome_link($alias) )
    }
    elsif ( $origin eq 'Mint' ) {
        return ( alias_mint_link($alias) );
    }
    elsif ( $origin eq 'Pubmed' ) {
        return ( alias_pubmed_link($alias) );
    }
    elsif ( $alias =~ m/^[XN]P/ ) {
        return ( alias_reflink($alias) );
    }
    elsif ( $origin =~ m/GeneHub/ ) {
        return ( alias_ghlink($alias) );
    }
    else {
        return ( $_[0] );
    }
}

sub alias_proteome_link {
    my $alias = shift;
"<a tooltip=\"link to Proteome for $alias\" href=\"http://research/products/proteome/cgi-bin/SearchSync.cgi?Mode=name&submit=Name/ID&current=human&pattern=$alias\">$alias</a>";

    #view-source:http://research/products/proteome/HumanPD/TNF.html
    #<form action="/products/proteome/cgi-bin/SearchSync.cgi" method="POST">
    #<b>Quick Search:</b>
    #<input type="text"   name="pattern" size="20">
    #<input type="hidden" name="Mode"    value="name">
    #<input type="submit" name="submit"  value="Name/ID">
    #<input type="hidden" name="current" value="human">
    #</form>
}

sub alias_gglink {
    $_[0] =~
s%^(UNQ|PRO|DNA)(\d+)$%<a tooltip=\"link to GenenGenes:$_[0]\" href="http://research/projects/gg/jsp/$1.jsp?$1ID=$2">$&</a>%;
    $_[0];
}

sub alias_ghlink {
"<a tooltip=\"link to GeneHub:$_[0]\" href=\"http://research/genehub/jsp/SearchAction.jsp?searchVal0=$_[0]\">$_[0]</a>";
}

sub alias_splink {
"<a tooltip=\"link to SwissProt:$_[0]\" href=\"http://us.expasy.org/cgi-bin/niceprot.pl?$_[0]\">$_[0]</a>";
}

sub alias_uniprot_link {
"<a tooltip=\"link to Uniprot:$_[0]\" href=\"http://www.uniprot.org/entry/$_[0]\">$_[0]</a>";
}

sub alias_reflink {
"<a tooltip=\"link to RefSeq:$_[0]\" href=\"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Search&db=Protein&term=$_[0]\">$_[0]</a>";
}

sub alias_enslink {
"<a tooltip=\"link to Ensembl:$_[0]\" href=\"http://www.ensembl.org/Homo_sapiens/textview?species=All&idx=Protein&q=$_[0]\">$_[0]</a>";
}

sub alias_mint_link {
"<a tooltip=\"link to Mint:$_[0]\" href=\"http://mint.bio.uniroma2.it/mint/search/window0.php?swisstrembl_ac=$_[0]\">$_[0]</a>";
}

sub alias_pubmed_link {
"<a tooltip=\"link to PubMed:$_[0]\" href=\"http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids=$_[0]\">$_[0]</a>";
}

sub pseq_summary_link {
    my ( $pseq_id, $tag ) = @_;
    return (
"<a tooltip=\"link to summary of Unison:$pseq_id\" href=\"pseq_summary.pl?pseq_id=$pseq_id\">$tag</a>"
    );
}

sub text_wrap {

    #local $Text::Wrap::break = qr/\s|(?:[,=])/;
    local $Text::Wrap::unexapand = 0;
    return Text::Wrap::wrap( '', '', map { s/,/, /g; $_ } grep { defined } @_ );
}

sub coalesce {

    # return first not null element of args, or undef
    # à la SQL's coalesce
    while ( @_ and not defined $_[0] ) {
        shift;
    }
    return $_[0];    # may be undef if list exhausted
}

1;
