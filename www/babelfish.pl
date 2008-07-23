#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/../perl5", "$FindBin::RealBin/../perl5-ext";

use Unison;
use Unison::Exceptions;
use Unison::SQL;
use Unison::pseq;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::WWW::utilities qw( ext_link pseq_summary_link );


my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

try {
  print $p->render( 'BabelFish -- Alias Translator',
					build_form($p),
					do_search($p)
				  );
} catch Unison::Exception with {
    $p->die(shift);
};

exit(0);



############################################################################
## Internals


sub build_form {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();


  return $p->group( 'Query',
					$p->start_form( -method => 'GET' ),
					'<table border=0 width="100%"><tr>',

					'<td style="vertical-align: top;" width="50%">',
					'<b>Enter protein accessions or identifiers...</b>',
					'<br>',
					$p->textarea(-name => 'aliases', 
								 -default => $p->{aliases} || '',
								 -rows => 5,
								 -columns => 60),
					'<br>',
					$p->note('Whitespace and commas will be
					removed. Identifiers must match exactly.'),
					'</td>',

					'<td>',
#					'<td style="vertical-align: top; border-left: thin dotted;">',
#					'<b>Select optional annotations...</b>',
#					'<br>(the site of future expansion)',
					'</td>',
					'</tr></table>',
					$p->submit( -name => 'submit',
								-value => 'submit' ),
					$p->end_form()
				  );
}


sub do_search {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();

  return unless defined $v->{submit};

  my $sth_a = $u->prepare_cached(qq(SELECT origin,alias,descr,tax_id,pseq_id,link_url
									FROM current_annotations_v
									WHERE upper(alias)=upper(?)
										  AND ann_pref IS NOT NULL
									));
  my $sth_oa = $u->prepare_cached(qq(SELECT origin,alias,descr,tax_id,pseq_id,link_url
									FROM current_annotations_v
									WHERE origin_id=origin_id(?) 
										  AND upper(alias)=upper(?)
								          AND ann_pref IS NOT NULL
								  	));
  my $sth_t = $u->prepare_cached(qq(SELECT *
									FROM current_annotations_v
									WHERE pseq_id=?
								          AND ann_pref IS NOT NULL
									));

  my @bg_colors = ( '#ccc', '#eee' );

  my @cols = (
			  'Query',
			  'Hit',
			  'MD5',
			  'Unison',
			  'RefSeq',
			  'UniProt',
			  'IPI',
			  'Ensembl',
			  'STRING'
			 );

  my $table = join('',
				   '<table class="uwtable">',
				   '<tr>',
				   (map { "<th>$_</th>" } @cols),
				   '</tr>'
				  );

  my $row_num = 0;
  my @aliases = grep { m/\S/ } split(/[\s,]+/,$v->{aliases});
  foreach my $query (@aliases) {
	my $sth;
	my @q_results;						 # row results for this query

	# Search aliases within an origin if the alias is of the format
	# <origin>:<alias>, otherwise just by the alias.  There may be more
	# than one hit to a given alias, but this is extremely rare for
	# commonly used aliases.
	if ($query =~ m/^([^:]+):([^:]+)$/) {
	  $sth = $sth_oa;
	  $sth_oa->execute($1,$2);
	} else {
	  $sth = $sth_a;
	  $sth_a->execute($query);
	}

	while( my $hit = $sth->fetchrow_hashref() ) {
	  # There's exactly one pseq_id per hit (by definition -- any alias is
	  # unique within an origin).  For each hit, gather the column data.
	  # The column data is a hash of arrays of formatted links.

	  my %col_data = ( MD5 => [],
					   RefSeq => [],
					   Ensembl => [],
					   IPI => [],
					   UniProt => [],
					   STRING => []
					 );

	  $sth_t->execute($hit->{pseq_id});
	  while( my $t = $sth_t->fetchrow_hashref() ) {
		# Each "target" is an annotation for this hit's pseq_id
		# These are binned by origin
		my $content;
		if ($t->{origin} =~ m/^(MD5)$/) {
		  $content = $t->{alias};
		} else {
		  $content = ext_link( $t->{link_url},
							   $t->{alias},
							   $t->{descr} );
		}

		my $origin = ( ($t->{origin} =~ m/^Ensembl/)
					   ? 'Ensembl'
					   : ($t->{origin} =~ m/^UniProt/)
					   ? 'UniProt'
					   : $t->{origin} );
		push( @{$col_data{$origin}}, $content );
	  }

	  push(@q_results, join('',
							map { "<td>$_</td>" }
							(defined $hit->{link_url} 
							 ? ext_link( $hit->{link_url}, 
										 "$hit->{origin}:$hit->{alias}",
										 $hit->{descr} )
							 : "$hit->{origin}:$hit->{alias}" ),
							join('<br>',@{$col_data{MD5}}),
							pseq_summary_link($hit->{pseq_id},undef),
							join('<br>',@{$col_data{RefSeq}}),
							join('<br>',@{$col_data{UniProt}}),
							join('<br>',@{$col_data{IPI}}),
							join('<br>',@{$col_data{Ensembl}}),
							join('<br>',@{$col_data{STRING}}),
						   )
		  );

	}

	if (not @q_results) {
	  push(@q_results, sprintf('<td colspan=%d><i>no such alias</i></td>',
							   $#cols+1));
	}

	my $row_bgcolor = $bg_colors[ $row_num++ % ($#bg_colors + 1) ];
	for(my $i=0; $i<=$#q_results; $i++) {
	  my $q_results = '';
	  if ($i==0) {
		$q_results = sprintf('<td rowspan=%d>%s</td>',
							 $#q_results+1,$query);
	  }
	  $q_results .= $q_results[$i];
	  $table .= "<tr bgcolor=\"$row_bgcolor\">" . $q_results . "</tr>\n";
	}

  } ## each alias

  $table .= "</table>\n";
  $table =~ s/<tr/\n<tr/g;

  return $table
}

