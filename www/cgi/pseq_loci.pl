#!/usr/bin/env perl

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $margin = 5000;						# margin around gene for geode

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
my $v = $p->Vars();

my $sql = qq/select pstart,pstop,pct_ident,G.name,chr,gstart,gstop
			from blatloci L  join genasm G on L.genasm_id=G.genasm_id where L.pseq_id=$v->{pseq_id}/;
my $ar = $u->selectall_arrayref($sql);


my @f = ('pstart-pstop', '% ident', 'genome name', 'gstart-gstop' );
for(my $i=0; $i<=$#$ar; $i++) {
  splice(@{$ar->[$i]},4,3,geode_link(@{$ar->[$i]}[4..6]));
  splice(@{$ar->[$i]},0,2,"$ar->[$i]->[0]-$ar->[$i]->[1]");
}

print $p->render("Loci of Unison:$v->{pseq_id}",
				 $p->best_annotation($v->{pseq_id}),
				 $p->group("Loci",
						   Unison::WWW::Table::render(\@f,$ar)),
				 $p->sql($sql)
				);

sub geode_link {
  my ($chr,$gstart,$gstop) = @_;
  return sprintf('<a href="%s"><img src="../av/geode.png">%d:%d-%d</a>',
				 geode_url($chr, $gstart-$margin, $gstop+$margin),
				 $chr, $gstart, $gstop);
}

sub geode_url {
  my ($chr,$gstart,$gstop) = @_;
  return "/~rkh/csb/unison/bin/chr_view.pl?chr=$chr&gstart=$gstart&gstop=$gstop";
  }
