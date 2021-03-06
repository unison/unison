#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::Exceptions;
use Error qw(:try);

my $margin = 5000;    # margin around gene for genome map

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my @ps = $u->get_params_info_by_pftype('pmap');
$v->{params_id} = $ps[0]->[0] unless ( defined $v->{params_id} );

# BUG: the genasm_id isn't passed to the Unison or geode views.
# genasm_id=2 (NHGD 35) because that's all geode supports and I don't want
# to show incorrect coords. This needs a better solution.

# TODO: should add inline frame with <div> and javascript frame
# updates. Consider new cgi class for embeddable features, e.g.,
# embed_genome_features.pl which returns just the graphic and image map.

my $sql = <<EOSQL;
SELECT params_id,pstart,pstop,pct_ident,pct_cov,L.genasm_id,G.tax_id,T.latin,G.name as genome_name,chr,strand,gstart,gstop
FROM pmap_mv L
JOIN genasm G ON L.genasm_id=G.genasm_id
JOIN tax.spspec T on G.tax_id=T.tax_id
WHERE L.genasm_id=G.genasm_id AND L.params_id=$v->{params_id} AND L.pseq_id=$v->{pseq_id}
ORDER BY tax_id,genasm_id,chr
EOSQL

my @cols = (
    'protein start-stop', '% identity', '% coverage', 'species',
    'genome name',  'locus',   'inset'
);    #, 'links' );

try {
    my @data;
	my $first_hit;
    my $sth = $u->prepare($sql);
    $sth->execute();

    while ( my $r = $sth->fetchrow_hashref() ) {
		my $fx = sprintf('update_emb_genome_map(%d,\'%s\',%d,%d,%d)',
						 $r->{genasm_id}, $r->{chr},
						 $r->{gstart} - $margin,
						 $r->{gstop} + $margin,
						 $v->{params_id}
						);
		if (not defined $first_hit) {
		  $first_hit = sprintf('emb_genome_map.pl?genasm_id=%d;chr=%s;gstart=%d;gstop=%d;params_id=%d',
							   $r->{genasm_id},
							   $r->{chr},
							   $r->{gstart} - $margin,
							   $r->{gstop} + $margin,
							   $v->{params_id}
							  );
		}

        my (%row_data) = map { $_ => '' } @cols;
        $row_data{'protein start-stop'} =
          sprintf( '%d-%d', $r->{pstart}, $r->{pstop} );
        $row_data{'% identity'}     = $r->{pct_ident};
        $row_data{'% coverage'}       = $r->{pct_cov};
        $row_data{'species'}     = $r->{latin};
        $row_data{'genome name'} = $r->{genome_name};
        $row_data{'locus'}       = sprintf( '%s%s:%d-%d',
            $r->{chr}, $r->{strand}, $r->{gstart}, $r->{gstop} );
        $row_data{'inset'} = "<a href=\"javascript:$fx\">show</a>";
        #$row_data{'links'} = genome_links($r);
        push( @data, [ map { $row_data{$_} } @cols ] );
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
  emb_elem.style.display = 'block';
  }
}
</script>
EOJS

    print $p->render(
        "Loci of Unison:$v->{pseq_id}",
        $p->best_annotation( $v->{pseq_id} ),
        $p->group(
            "Loci",
            '<div>',    # div solely so that
            $js,        # js is in block element
            Unison::WWW::Table::render( \@cols, \@data ),
            '</div>'
        ),
'<p><iframe id="emb_genome_map" src="'.$first_hit.'" width="100%" height="400px" scrolling="auto">',
'Sorry. I cannot display alignments because your browser does not support iframes.',
        '</iframe>',

        $p->sql($sql)
    );
}
catch Unison::Exception with {
    $p->die( 'SQL Query Failed', $_[0], $p->sql($sql) );
};

exit(0);

sub genome_links {
    my $r = shift;
    my @links;
    my (%ucsc_tax_id_map) = ( 9606 => [ 'Human', 'hg17' ] );

    push(
        @links,
        sprintf(
'<a href="genome_features.pl?genasm_id=%d;chr=%d;gstart=%d;gstop=%d;params_id=%d"><img border=0 tooltip="view genomic region in Unison" src="../av/favicon.gif"></a>',
            $r->{genasm_id}, $r->{chr}, $r->{gstart},
            $r->{gstop},     $v->{params_id}
        )
    );

# UCSC browser links are broken... apparently the coords are not the same!
# (exists $ucsc_tax_id_map{$r->{tax_id}}) {
#push(@links,
#	 sprintf('<a href="http://genome.ucsc.edu/cgi-bin/hgTracks?org=%s&db=%s&position=chr%s%3A%d-%d&pix=620&Submit=submit">UCSC</a>',
#			 @{$ucsc_tax_id_map{$r->{tax_id}}},$r->{chr},$r->{gstart},$r->{gstop}));
#}

    return join( ' ', @links );
}
