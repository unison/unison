#!/usr/bin/env perl

use strict;
use warnings;
use Data::Dumper;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my $sql = qq/select target,best_annotation(target),qstart||'-'||qstop,tstart||'-'||tstop,
			len,ident,sim,gaps,eval,
			pct_ident,pct_hsp_coverage,pct_coverage
			from blast_results($v->{pseq_id})
			order by pct_ident desc,len desc,eval/;

my $ar = $u->selectall_arrayref($sql) ;
splice(@$_,0,2,mk_palias_link($_->[0],$_->[1])) for @$ar;

my @f = ( 'target',"Unison:$v->{pseq_id}<br>qstart-qstop",'target<br>stop-start','len',
		  'ident','sim','gaps','eval','identity (%)',
		  'HSP coverage (%)','coverage (%)' );

print $p->render("Near-identity BLASTs of Unison:$v->{pseq_id}",
				 $p->best_annotation($v->{pseq_id}),
				 $p->tip('hover over entries in the target column to see annotations'),
				 $p->group("BLASTS Unison:$v->{pseq_id}",
						   Unison::WWW::Table::render(\@f,$ar)),
				 $p->sql($sql)
				);


sub mk_palias_link {
#  return( "<a href=\"pseq_paliases.pl?pseq_id=$_[0]\" tooltip='$_[1]'>$_[0]</a>" );
  return( sprintf("<a href=\"pseq_paliases.pl?pseq_id=$_[0]\" tooltip='%s'>$_[0]</a>",
				  (defined $_[1] ? $_[1] : '<no annotation>')) );
}
