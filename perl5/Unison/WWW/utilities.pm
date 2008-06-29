package Unison::WWW::utilities;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;
use base 'Exporter';
our @EXPORT_OK = qw(
					 alias_enslink alias_gglink alias_ghlink alias_link
					 alias_mint_link alias_proteome_link alias_pubmed_link
					 alias_reflink alias_splink alias_uniprot_link
					 coalesce genengenes_link homologene_link html_link
					 maprofile_link ncbi_gene_link ncbi_refseq_link
					 pdbc_rcsb_link pfam_link pseq_annotations_link
					 pseq_functions_link pseq_summary_link render_app_list
					 text_wrap
				  );

our @EXPORT = ();

use Text::Wrap;
use Data::Dumper;

# TODO:
# The URL formats /should/ come from the origin table (origin.url)
# using Unison::links.  However, those need a Unison ref and these
# functions don't provide such.

## TODO: functions should be "thinner"... just return the URL and use
## alias_link to construct the <a..></a>


sub alias_link {
    my ( $alias, $origin ) = @_;

	# origin eq
    if ( $origin eq 'GenenGenes' ) {
        return ( alias_gglink($alias) );
    }
    elsif ( $origin eq 'Swiss-Prot' ) {
        return ( alias_splink($alias) );
    }
    elsif ( $origin eq 'Mint' ) {
        return ( alias_mint_link($alias) );
    }
    elsif ( $origin eq 'STRING' ) {
        return ( alias_string_link($alias) );
    }
    elsif ( $origin eq 'Pubmed' ) {
        return ( alias_pubmed_link($alias) );
    }
    elsif ( $origin eq 'IPI' ) {
        return ( alias_ipi_link($alias) );
    }

	# origin =~
    elsif ( $origin =~ m/^UniProt/i ) {
        return ( alias_uniprot_link($alias) );
    }
    elsif ( $origin =~ m/^Ensembl/i ) {
        return ( alias_ensembl_link($alias) );
    }
    elsif ( $origin =~ m/GeneHub/ ) {
        return ( alias_ghlink($alias) );
    }
    elsif ( $origin =~ m/^CCDS/ ) {
        return ( alias_ccds_link($alias) );
    }

	# alias =~
    elsif ( $alias =~ m/^[XN]P/ ) {
        return ( alias_reflink($alias) );
    }

    else {
        return ( $_[0] );
    }
}

sub alias_proteome_link {
  return unless defined $_[0];
  extlink('http://research/products/proteome/cgi-bin/SearchSync.cgi?Mode=name&submit=Name/ID&current=human&pattern='.$_[0],
		  $_[1]||$_[0]);
}

sub alias_gglink {
  goto &genengenes_link;
}
sub genengenes_link {
  return unless defined $_[0];
  my ($d,$id) = $#_ == 0 ? $_[0] =~ m/^(UNQ|PRO|DNA)(\d+)/ : @_;
  return unless (defined $d and defined $id);
  extlink("http://research/projects/gg/jsp/$d.jsp?${d}ID=$id",$_[0]);
}

sub alias_ghlink {
  return unless defined $_[0];
  extlink('http://research/genehub/jsp/SearchAction.jsp?searchVal0='.$_[0],
		  $_[1]||$_[0]);
}

sub alias_string_link {
  return unless defined $_[0];
  extlink('http://string.embl.de/newstring_cgi/show_network_section.pl?identifier='.$_[0],
		  $_[1]||$_[0]);
}

sub alias_ccds_link {
  return unless defined $_[0];
  extlink('http://www.ncbi.nlm.nih.gov/CCDS/CcdsBrowse.cgi?REQUEST=CCDS&DATA='.$_[0],
		  $_[1]||$_[0]
		 );
}

sub alias_ipi_link {
  return unless defined $_[0];
  extlink(sprintf("http://srs.ebi.ac.uk/srsbin/cgi-bin/wgetz?-e+[IPI:'%s']",$_[0]),
		  $_[1]||$_[0]
		 );
}

sub alias_ensembl_link {
  return unless defined $_[0];
  extlink('http://www.ensembl.org/Homo_sapiens/searchview?species=;idx=;q='.$_[0],
		  $_[1]||$_[0]);
}

sub homologene_link {
  return unless defined $_[0];
  extlink('http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=homologene&term='.$_[0],
		  $_[1]||$_[0]);
}

sub pfam_link {
  return unless defined $_[0];
  extlink("http://pfam.janelia.org/family?entry=$_[0]",
		  $_[1]||$_[0]);
}

sub alias_splink {
  return unless defined $_[0];
  extlink('http://us.expasy.org/cgi-bin/niceprot.pl?'.$_[0],
		  $_[1]||$_[0]);
}

sub alias_uniprot_link {
  return unless defined $_[0];
  extlink('http://www.uniprot.org/entry/'.$_[0],$_[1]||$_[0]);
}

sub alias_enslink {
  return unless defined $_[0];
  extlink('http://www.ensembl.org/Homo_sapiens/textview?species=All&idx=Protein&q='.$_[0],
		  $_[1]||$_[0]);
}

sub alias_mint_link {
  return unless defined $_[0];
  "<a class=\"extlink\" target=\"_blank\" href=\"http://mint.bio.uniroma2.it/mint/search/window0.php?swisstrembl_ac=$_[0]\">$_[0]</a>";
}

sub alias_pubmed_link {
    return unless defined $_[0];
    extlink('http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?cmd=Retrieve&db=pubmed&dopt=Abstract&list_uids='.$_[0],
	    $_[1]||$_[0]);
}

sub maprofile_link {
  # IN: <chip,probe> or 'chip:probe'
  return unless defined $_[0];
  my ($chip,$probe) = $#_ == 0 ? $_[0] =~ m/(\w+):(\w+)/ : @_;
  return unless (defined $chip and defined $probe);
  extlink("http://research/maprofile/cgi-bin/maprofile.cgi?probeid=$probe","$chip:$probe");
}

sub alias_reflink {
  return unless defined $_[0];
  ncbi_refseq_link($_[0],$_[0]);
}


sub pdbc_rcsb_link {
  return unless defined $_[0];
  extlink('http://www.rcsb.org/pdb/explore/explore.do?structureId='.uc($_->[0]),$_->[0]);
}

sub ncbi_refseq_link {
  return unless defined $_[0];
  extlink('http://www.ncbi.nlm.nih.gov/sites/entrez?holding=&db=protein&cmd=search&term='.$_[0],
		  $_[1]||"RefSeq:$_[0]");
}

sub ncbi_gene_link {
  return unless defined $_[0];
  extlink('http://www.ncbi.nlm.nih.gov/sites/entrez?Db=gene&Cmd=Retrieve&dopt=full_report&log$=databasead&list_uids='.$_[0],
		  $_[1]||"GeneID:$_[0]");
}

sub pseq_summary_link {
  int_link("pseq_summary.pl?pseq_id=$_[0]",
		   $_[1]||"Unison:$_[0]",
		   $_[2]);
}
sub pseq_annotations_link {
  int_link("pseq_annotations.pl?pseq_id=$_[0]",
		   $_[1]||"Unison:$_[0]",
		   $_[2]);
}
sub pseq_functions_link {
  int_link("pseq_functions.pl?pseq_id=$_[0]",
		   $_[1]||"Unison:$_[0]",
		   $_[2]);
}


# should use hashes here (and, really, probably everywhere)
sub int_link {
  sprintf('<a href="%s"%s>%s</a>',
		  $_[0],
		 (defined $_[2] ? ' tooltip="'.$_[2].'"' : ''),
		  $_[1]
		 );
}
sub extlink {
  sprintf('<a class="extlink" target="_blank" href="%s"%s>%s</a>', 
		  $_[0],
		 (defined $_[2] ? ' tooltip="'.$_[2].'"' : ''),
		  $_[1],
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

sub render_app_list {
  my $prd_only = shift;
  my $pub_only = shift;

  my @apps = @_;
  if ($prd_only) {
	print(STDERR "removing non-prd elems\n");
	@apps = grep { defined $_->{prd} } @apps;
  }
  if ($pub_only) {
	print(STDERR "removing non-pub elems\n");
	@apps = grep { defined $_->{pub} } @apps;
  }

  return(
		 qq(<div class="top">\n<dl>\n), 
		 ( map { _format_app_entry($_) } @apps ),
		 qq(</dl>\n</div>\n)
		)
}

sub _format_app_entry {
  my $ae = shift;
  my $tags = ($ae->{prd} ? '' : 'D') . ($ae->{pub} ? '' : 'P');
  $tags = "($tags)" if $tags;
  return <<EOHTML;
<dt><a href="$ae->{script}">$ae->{name}</a> $tags - $ae->{brief}
<dd>$ae->{descr}
EOHTML
}


1;
