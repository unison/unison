#!/usr/bin/env perl

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my $sql = qq/select pstart,pstop,genome.name,chr,gstart,gstop,ident,eval
			from plocus natural join genome where plocus.pseq_id=$v->{pseq_id}/;
my $ar = $u->selectall_arrayref($sql);
my @f = ('pstart', 'pstop', 'genome name', 'chr', 'gstart', 'gstop', 'ident', 'eval' );


for(my $i=0; $i<=$#$ar; $i++) {
  $ar->[$i]->[4] = geode_link($ar->[$i]);
}


print $p->render("Loci of Unison:$v->{pseq_id}",
				 $p->best_annotation($v->{pseq_id}),
				 $p->group("Loci",
						   Unison::WWW::Table::render(\@f,$ar)),
				 $p->sql($sql)
				);


sub geode_link {
  my $r = shift;
  my %r = ( chr => $r->[3], gstart => $r->[4], gstop => $r->[5] );
  my $chr_margin = 5000;						# margin around gene for geode
  sprintf('<a href="/~rkh/csb/unison/bin/chr_view.pl?chr=%s&gstart=%d&gstop=%d"><img src="/~rkh/csb/unison/av/geode.png">%d</a>',
		  					   $r{chr}, $r{gstart}-$chr_margin, $r{gstop}+$chr_margin,$r{gstart});
  }
