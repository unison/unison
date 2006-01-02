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


my $margin = 5000;						# margin around gene for genome map

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();
$p->add_footer_lines('$Id: pseq_loci.pl,v 1.21 2005/12/07 23:21:02 rkh Exp $ ');


my @ps = $u->get_params_info_by_pftype('pmap');

if (not defined $v->{params_id}) {
  $v->{params_id} = 
	$u->get_current_params_id_by_pftype($v->{pseq_id},'pmap')
	|| $ps[0]->[0];
}

## BUG: the genasm_id isn't passed to the Unison or geode views.
# genasm_id=2 (NHGD 35) because that's all geode supports and I don't want
# to show incorrect coords. This needs a better solution.

# FEATURE: should add inline frame with <div> and 
# javascript frame updates. Consider new cgi class for 
# embeddable features, e.g., embed_genome_features.pl 
# which returns just the graphic and image map.


my $sql = <<EOSQL;
SELECT params_id,pstart,pstop,pct_ident,pct_cov,L.genasm_id,G.tax_id,T.latin,G.name as genome_name,chr,(case plus_strand when true then '+' else '-' end) as strand,gstart,gstop
FROM pmap_v L
JOIN genasm G ON L.genasm_id=G.genasm_id
JOIN tax.spspec T on G.tax_id=T.tax_id
WHERE L.genasm_id=G.genasm_id AND L.params_id=$v->{params_id} AND L.pseq_id=$v->{pseq_id}
ORDER BY tax_id,genasm_id,chr
EOSQL

my @cols = ('pstart-pstop', '% ident', '% cov', 'species', 'genome name', 'locus', 'inset' ); #, 'links' );


try {
  my @data;
  my $sth = $u->prepare($sql);
  $sth->execute();

  while ( my $r = $sth->fetchrow_hashref() ) {
	my (%row_data) = map { $_ => '' } @cols;
	$row_data{'pstart-pstop'} = sprintf('%d-%d',$r->{pstart},$r->{pstop});
	$row_data{'% ident'} = $r->{pct_ident};
	$row_data{'% cov'} = $r->{pct_cov};
	$row_data{'species'} = $r->{latin};
	$row_data{'genome name'} = $r->{genome_name};
	$row_data{'locus'} = sprintf('%s%s:%d-%d',$r->{chr},$r->{strand},$r->{gstart},$r->{gstop});
	$row_data{'inset'} = sprintf('<a href="javascript:update_emb_genome_map(%d,\'%s\',%d,%d,%d)">show</a>',
								 $r->{genasm_id},$r->{chr},$r->{gstart}-$margin,$r->{gstop}+$margin,$v->{params_id});
	#$row_data{'links'} = genome_links($r);
	push(@data, [map {$row_data{$_}} @cols]);
  }

  my $js = <<EOJS;
<script type="text/javascript" language="javascript">
function update_emb_genome_map(genasm_id,chr,gstart,gstop,params_id) {
var emb_elem = document.getElementById('emb_genome_map');
if (emb_elem) {
  var emb_url = 'emb_genome_map.pl?';
  emb_url += 'genasm_id='+genasm_id;
  emb_url += ';chr='+chr;
  emb_url += ';gstart='+gstart+';gstop='+gstop;
  emb_url += ';params_id='+params_id;
  emb_elem.setAttribute('src', emb_url);
  }
}
</script>
EOJS

  print $p->render("Loci of Unison:$v->{pseq_id}",
				   $p->best_annotation($v->{pseq_id}),
				   $p->group("Loci",
							 '<div>',		# div solely so that
							 $js,			# js is in block element
							 Unison::WWW::Table::render(\@cols,\@data),
							'</div>'),
				   '<p><iframe id="emb_genome_map" width="100%" height="300px" scrolling="yes">',
				   'Sorry. I cannot display alignments because your browser does not support iframes.',
				   '</iframe>',

				   $p->sql($sql)
				  );
} catch Unison::Exception with {
  $p->die('SQL Query Failed',
		  $_[0],
		  $p->sql($sql));
};

exit(0);


sub genome_links {
  my $r = shift;
  my @links;
  my (%ucsc_tax_id_map) = ( 9606 => ['Human','hg17'] );

  push(@links,
	   sprintf('<a href="genome_features.pl?genasm_id=%d;chr=%d;gstart=%d;gstop=%d;params_id=%d"><img border=0 tooltip="view genomic region in Unison" src="../av/favicon.gif"></a>',
			   $r->{genasm_id},$r->{chr},$r->{gstart},$r->{gstop},$v->{params_id}));

  # UCSC browser links are broken... apparently the coords are not the same!
  # (exists $ucsc_tax_id_map{$r->{tax_id}}) {
  #push(@links,
  #	 sprintf('<a href="http://genome.ucsc.edu/cgi-bin/hgTracks?org=%s&db=%s&position=chr%s%3A%d-%d&pix=620&Submit=submit">UCSC</a>',
  #			 @{$ucsc_tax_id_map{$r->{tax_id}}},$r->{chr},$r->{gstart},$r->{gstop}));
  #}

  return join(' ', @links);
}
