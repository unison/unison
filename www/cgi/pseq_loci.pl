#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::Exceptions;
use Error qw(:try);


my $margin = 5000;						# margin around gene for geode

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$p->add_footer_lines('$Id: pseq_loci.pl,v 1.14 2005/06/18 00:16:45 rkh Exp $ ');


## BUG: the genasm_id isn't passed to the Unison or geode views.
# genasm_id=2 (NHGD 35) because that's all geode supports and I don't want
# to show incorrect coords. This needs a better solution.

# FEATURE: should add inline frame with <div> and 
# javascript frame updates. Consider new cgi class for 
# embeddable features, e.g., embed_genome_features.pl 
# which returns just the graphic and image map.

my $sql = qq/select pstart,pstop,pct_ident,G.name,chr,gstart,gstop
			from blatloci L  join genasm G on L.genasm_id=G.genasm_id where G.genasm_id=2 and L.pseq_id=$v->{pseq_id}/;


try {
  my $ar = $u->selectall_arrayref($sql);

  my @f = ('pstart-pstop', '% ident', 'genome name', 'gstart-gstop' );
  for(my $i=0; $i<=$#$ar; $i++) {
	splice(@{$ar->[$i]},4,3,genome_link(@{$ar->[$i]}[4..6]));
	splice(@{$ar->[$i]},0,2,"$ar->[$i]->[0]-$ar->[$i]->[1]");
  }

  print $p->render("Loci of Unison:$v->{pseq_id}",
				   $p->best_annotation($v->{pseq_id}),
				   '<p> THIS PAGE IS UNDER DEVELOPMENT.',
				   '<p>',
				   $p->group("Loci",
							 Unison::WWW::Table::render(\@f,$ar)),
				   $p->sql($sql)
				  );
} catch Unison::Exception with {
  $p->die('SQL Query Failed',
		  $_[0],
		  $p->sql($sql));
};

exit(0);


sub genome_link {
  my ($chr,$gstart,$gstop) = @_;
  return sprintf('%d:%d-%d <a href="%s"><img border=0 tooltip="view genomic region in Unison" src="../av/favicon.gif"></a> <a href="%s"><img border=0 tooltip="view genomic region with geode" src="../av/geode.png"></a>',
				 $chr, $gstart, $gstop,
				 unison_url($chr, $gstart-$margin, $gstop+$margin),
				 geode_url($chr, $gstart-$margin, $gstop+$margin));
}


sub geode_url {
  my ($chr,$gstart,$gstop) = @_;
  return "http://research/geode/browseGenome.do?queryType=chromosome&start=$gstart&end=$gstop&chromosome=$chr";
  }

sub unison_url {
  my ($chr,$gstart,$gstop) = @_;
  ### WARNING: HARDWIRED genasm_id
  return "genome_features.pl?genasm_id=1;chr=$chr;gstart=$gstart;gstop=$gstop";
  }
