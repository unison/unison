############################################################
# compare_scores.pm
# Methods for Assess TAB, compare scores and compare methods
# $ID = q$Id: compare_scores.pm,v 1.1 2005/03/21 22:26:55 mukhyala Exp $;
############################################################

package Unison::Utilities::compare_scores;
use CBT::debug;
CBT::debug::identify_file() if ($CBT::debug::trace_uses);

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = ();
our @EXPORT_OK = qw(get_p2_scores get_scop_pdb  display_points display_bars display_table %params );

use GD::Graph::points;
use GD::Graph::mixed;
use GD::Graph::bars;
use GD::Graph::Map;
use Statistics::Basic::Mean;
use Statistics::Basic::StdDev;

use Unison::WWW::Page;
use Unison::WWW::Table;
use Unison::SQL;
use Unison::Utilities::Cluster;

sub compute_stats($);
sub plot_stats($$);
sub get_p2_scores($$$);
sub get_scop_pdb($);
sub display_points($);
sub display_bars($);
sub display_table($);

my %params =
 (
  nclusters => 4,
  algorithm => "kcluster",
  associate => ['white','yellow','blue','red','grey'] # in the order of increasing scores
  );

my $scopURL = 'http://scop.berkeley.edu/search.cgi?sunid=';
my $pdbURL = 'http://www.rcsb.org/pdb/cgi/explore.cgi?pdbId=';

my ($pmodel_scop,$pmodel_pdb);
my ($scores,$sp,$data, $stats_data);
##
## 1. get pseqs,pmodels of pmodelset
## 2. get pseqs of universal_seq_set (pset_id=52)
## 3. subtract pseqs from universal_set_pseqs
## 4. set the $scores hash in this form:
## {model}{sequence} => score
##

sub get_p2_scores($$$) {

  my ($u,$v,$score) = @_;
  my (%test);
  my (@ms,@ps,@uniq,@univ);
  %params = (%params,%$v);

    #1
    @ms = @{ $u->selectall_arrayref( "select m.pseq_id,m.pmodel_id from pmprospect2 m join pmsm_prospect2 s on m.pmodel_id=s.pmodel_id where s.pmodelset_id=$params{pmodelset_id}" ) };
    my %ms = map { $_->[0] => $_->[1] } @ms;

    #2
    @ps = map {$_->[0]} @{$u->selectall_arrayref( "select pseq_id from pseqset where pset_id=52")};

    #3
    @test{keys %ms} = undef;
    @uniq = grep{!exists $test{$_}} @ps;
    @univ = (keys %ms, '0', @uniq);

    my $i = 0;
    %$sp = map {$_ => $i++;} @univ;

    #4
    if (%ms) {
      my $sql = Unison::SQL->new()
	->table('paprospect2')
	  ->columns($score)
	    ->columns('pmodel_id')
	      ->columns('pseq_id')
		->where('params_id = ' . $params{params_id})
		  ->where('pseq_id in (' . join(',',@univ) . ')')
		    #the 0 x 100 is a hack to force PG to choose a better(aka faster) execution plan!
		    ->where('pmodel_id in (' . join(',',(values %ms, (0) x 100)) . ')');

      my @sc = @{ $u->selectall_arrayref("$sql") };
      map {$$scores{$_->[1]}{$_->[2]} = $_->[0]} @sc;

    }
    foreach my $i (keys %$scores) {
      $$scores{$i}{'0'}=undef;
    }
  return ($scores);
}

##############################################################################
#set scores for dummy pseq '0' in order to separate known and known-not scores
sub draw_divider {

  my ($x_value) = @_;
  my ($min,$max) = min_max();
  my $inc = ($max-$min)/(scalar keys %$scores);
  my $num=1;
  foreach my $i (keys %$scores) {
    $$scores{$i}{$x_value}=$min + $inc * $num++;
  }
}

sub min_max {
  my ($min,$max);
   foreach my $i (keys %$scores) {
     foreach my $y (keys %{$$scores{$i}}) {
       my $val = $$scores{$i}{$y};
       $min = $val if defined $val && (!defined $min || $val < $min);
       $max = $val if defined $val && (!defined $max || $val > $max);
     }
   }
  return ($min,$max);
}
################################################################################

##
##Reorganize hash suitable for GD::Graph ploting
##X labels in first row and their values in subsequent rows
##and then plot
##
sub display_points($) {

  my ($png_fh) = @_;
  my ($cols,$rows,$temp,$imagerefs,$labelrefs);

  #set scores for dummy pseq '0' in order to separate known and known-not scores
  draw_divider('0');

  push @$cols, keys %$scores;
  foreach my $pseq(sort {$$sp{$a} <=> $$sp{$b}} keys %$sp) {
    push @$temp, $pseq if(exists( $$scores{$$cols[0]}{$pseq} ));
  }
  push @$data, $temp;#Pseqs in first row

  foreach my $model (sort @$cols) {
    my ($row,$url);
    foreach my $pseq(sort {$$sp{$a} <=> $$sp{$b}} keys %$sp ) {
      if( exists( $$scores{$model}{$pseq} ) ) {
	push @$row,$$scores{$model}{$pseq};
	push @$url, $pdbURL.substr($$pmodel_pdb{$model},0,4);
      }
    }
    push @$data, $row;#scores for pseqs with this model
    push @$imagerefs, $url;
    push @$labelrefs, $pdbURL.substr($$pmodel_pdb{$model},0,4);
  }
  my $map = _plot_points($imagerefs,$labelrefs,$png_fh);
  return ($data,$map);
}

##
## creates a xy points graph
##
sub _plot_points() {

  my ($imagerefs,$labelrefs,$png_fh) = @_;
  my $points_graph = GD::Graph::points->new(800, 500);

  $points_graph->set(
		x_label       => 'Sequence_ids',
		y1_label      => $params{score}." score",
		title         => 'Threading Scores for Sequences against Models',
		x_label_skip  => ($#{$$data[0]}/20)+1,
		x_all_ticks   => 1,
		y_tick_number => 10,
		marker_size   => 3,
		legend_placement => 'BC',
	       ) or warn $points_graph->error;

  #legend needs to be in the same order as data
  $points_graph->set_legend(map {$$pmodel_pdb{$_}} sort keys %$pmodel_pdb);
  _print_graph($points_graph,$png_fh);

  #create an imagemap for the graph
  my $map = new GD::Graph::Map($points_graph,
			    hrefs=>$imagerefs,
			   lhrefs=>$labelrefs,
        noImgMarkup=>1,
        mapName=>"scattermap",
        info => 'pseq= %x,  model = %l, score = %y',
	legend => [(map {$$pmodel_scop{$_}{'name'}."::".$$pmodel_scop{$_}{'descr'} if(defined($$pmodel_scop{$_}{'name'}))} sort keys %$pmodel_pdb)]
    );
  return $map;
}

sub display_bars($) {

  my ($png_fh) = @_;
  my ($cols,$temp,$mins,$maxs,$err_mins,$err_maxs,$err_meds,$divider_min,$divider_max);
  my ($min_all,$max_all) = min_max();

  push @$cols, keys %$scores;
  foreach my $pseq(sort {$$sp{$a} <=> $$sp{$b}} keys %$sp) {
    push @$temp, $pseq if(exists( $$scores{$$cols[0]}{$pseq} ));
  }
  push @$data, $temp;#Pseqs in first row

  foreach my $pseq(sort {$$sp{$a} <=> $$sp{$b}} keys %$sp ) {
    if( exists( $$scores{$$cols[0]}{$pseq} ) ) {
      my ($row,$min,$max);
      foreach my $model (sort @$cols) {
	my $val = $$scores{$model}{$pseq};
	push @$row,$val;
	$min = $val if !defined $min || $val < $min;
	$max = $val if !defined $max || $val > $max;
      }
      my $mo = new Statistics::Basic::Mean($row);
      my $sd = new Statistics::Basic::StdDev($row);

      push @$mins, $min;
      push @$maxs, $max;
      push @$err_mins, (defined($min) ? ($mo->query - $sd->query > $min ? $mo->query - $sd->query : $min) : undef);
      push @$err_maxs, (defined($max) ? ($mo->query + $sd->query < $max ? $mo->query + $sd->query : $max) : undef);
      push @$err_meds, (defined($$scores{$$cols[0]}{$pseq}) ? $mo->query : undef);
      push @$divider_max, undef unless ($pseq == 0);
      push @$divider_max, $max_all  if ($pseq == 0);
      push @$divider_min, undef unless ($pseq == 0);
      push @$divider_min, $min_all  if ($pseq == 0);
    }
  }
  push @$data,$mins;
  push @$data,$maxs;
  push @$data,$err_mins;
  push @$data,$err_maxs;
  push @$data,$err_meds;
  push @$data,$divider_max;
  push @$data,$divider_min;
  _plot_bars($png_fh);
}


##
## creates an error-bar style graph
##
sub _plot_bars {

  my ($png_fh) = @_;
  my $bar_graph = GD::Graph::mixed->new(800, 500);

  $bar_graph->set(	
		types         => ['bars','bars','bars','bars','points','bars','bars'],
		x_label       => 'Sequence_ids',
		y_label       => $params{score}." score",
		title         => 'Scoring Range for Known and Known-NOT sequences against known Models',
		markers       => [1],
		marker_size   => 1,
		x_label_skip  => ($#{$$data[0]}/20)+1,#skipping a label for every 20, X values.
		x_all_ticks   => 1,
		y_tick_number => 10,
		cumulate      => 1,
		error_bars    => 1
	       ) or warn $bar_graph->error;
  $bar_graph->set_legend('', 'Total Scoring Range', '', '1 Std. Dev Range', 'Mean Score');
  $bar_graph->set(dclrs => [('','blue','','lred','green','black','black')]);
  _print_graph($bar_graph,$png_fh);
}


## writes png image to a temp file
sub _print_graph {

  my($mygraph,$png_fh) = @_;

  $mygraph->set_x_label_font(GD::Font->Large);
  $mygraph->set_y_label_font(GD::Font->Large);
  $mygraph->set_x_axis_font (GD::Font->Small);
  $mygraph->set_y_axis_font (GD::Font->Small);
  $mygraph->set_title_font  (GD::Font->Giant);
  $mygraph->set_legend_font (GD::Font->MediumBold);
  $mygraph->set(
		axislabelclr  => 'red',
		labelclr      => 'dgreen',
		logo          => '../av/logo-50.png',
		logo_resize   => 0.25
		);

  my $myimage = $mygraph->plot($data) or die $mygraph->error;
  binmode $png_fh;
  print $png_fh $myimage->png;
  close $png_fh;

}

##
## Print clustered scores
## in a table form (models on X axis and pseqs on Y axis)
## with approp. bg colours
##

sub display_table($) {

  my ($u) = @_;
  my ($cols,$rows);
  my $c = Unison::Utilities::Cluster::new(%params);
  my $cluster_arr = $c->cluster_2dhash($scores);
  return "CLUSTERING OF THREADING SCORES FAILED!" if(!defined($cluster_arr));

  my $ret = '<STYLE>h1 {font-size:60%} </STYLE><FONT size="1"><table border=1><tr>';
  $ret .= '<th>seq/model</th>';

  #first row
  foreach (keys %$scores) {
    my $link = $_;
    if(exists($$pmodel_scop{$_})) {
      $link =  "<a href=\"$scopURL$$pmodel_scop{$_}{'sunid'}\" title=\"$$pmodel_scop{$_}{'name'}:$$pmodel_scop{$_}{'descr'}\">$$pmodel_scop{$_}{'name'}</a>";
    }
    else {
      $link =  "<a href=\"$pdbURL".substr($$pmodel_pdb{$_},0,4)."\"title=\"$$pmodel_pdb{$_}>$$pmodel_pdb{$_}\"</a>";
    }
    $ret .= '<th>'.$link.'</th>';#models on first row
  }

  #scores rows
  push @$cols, keys %$scores;
  foreach my $i(sort {$$sp{$a} <=> $$sp{$b}} keys %$sp) {
    next unless exists($$scores{$$cols[0]}{$i});

    if($i == 0) {$ret .= '</tr><tr>' x 4;}#seperation between knowns and known-nots
    else {
      my $link = "<a href=\"pseq_summary.pl?pseq_id=$i\" title=\"".$u->best_annotation($i)."\">$i</a>";
      $ret .= '</tr><tr><td height=10 ALIGN=center>'.$link.'</td>';#first col in each row is a pseq link

      foreach my $j(keys %$scores) {
	my $order = ($params{score} eq 'raw' ? -1 : 1);
	my $clr = $c->get_association($$scores{$j}{$i},$order);
	$ret .= sprintf("<td height=10 ALIGN=center bgcolor=%s><h1 title=%.2f>%.".($order == 1 ? 1 : 0)."f</h1></td>",$clr,$$scores{$j}{$i},$$scores{$j}{$i}) if(defined($$scores{$j}{$i}));
      }
    }
  }
  $ret .= '</tr></table></FONT>';
  return $ret;
}


sub get_scop_pdb($) {

  my ($u) = @_;

  my @pm_scop = @{ $u->selectall_arrayref('select pmodel_id,sp,pdb,descr from mukhyala.v_scop_pmodel where pmodel_id in  (' . join(',',keys %$scores) . ') order by pmodel_id') };

  map {$$pmodel_scop{$_->[0]}{'sunid'} = $_->[1]} @pm_scop;
  map {$$pmodel_scop{$_->[0]}{'name'}  = $_->[2]} @pm_scop;
  map {$$pmodel_scop{$_->[0]}{'descr'} = $_->[3]} @pm_scop;

  my @pm_pdb = @{ $u->selectall_arrayref('select pmodel_id,acc from pmprospect2 where pmodel_id in  (' . join(',',keys %$scores) . ') order by pmodel_id') };

  map {$$pmodel_pdb{$_->[0]} = $_->[1]} @pm_pdb;
}

sub compute_stats($) {

  my ($score) = @_;
  my $flag=0;
  my (@known_nots);

  foreach my $pseq(sort {$$sp{$a} <=> $$sp{$b}} keys %$sp ) {
    foreach my $model (sort keys %$scores) {
      $flag=1 if ($pseq eq '0');#0 is the separator
      next unless defined( $$scores{$model}{$pseq} );
      push @{$known_nots[$flag]}, $$scores{$model}{$pseq};
    }
  }

  return if($#{$known_nots[0]} < 0 || $#{$known_nots[0]} < 0);

  my @sorted_scores = sort {$score eq 'raw' ? $a <=> $b : $b <=> $a} (@{$known_nots[0]},  @{$known_nots[1]});

  my ($tp,$tn,$fp,$fn) = (0,0,0,0);
  foreach my $s(@sorted_scores) {
      foreach my $i(@{$known_nots[0]}) {
	  ($score eq 'raw' ? $tp++ : $fn++) if($i <= $s);
	  ($score eq 'raw' ? $fn++ : $tp++) if($i  > $s);
      }
      foreach my $i(@{$known_nots[1]}) {
	  ($score eq 'raw' ? $tn++ : $fp++) if($i  > $s);
	  ($score eq 'raw' ? $fp++ : $tn++) if($i <= $s);
      }

      my $sensitivity = $tp/($tp+$fn);
      my $specificity = $tn/($tn+$fp);
      $stats_data->{sprintf("%.2f",1-$specificity)}{$score} = sprintf("%.2f",$sensitivity);
  }
  return (1,1);
}

sub reorganize_stats($) {

  my ($xref) = @_;

  #create a data structure for a scatter plot with a numerical x axis
  foreach my $s (sort {$a <=> $b} keys %$stats_data) {
    my $y=0;
    # create a separate series for each y value ([1][0], [2][1], [3][2] ...)
    foreach (@$xref) {
      $y++;
      push @{$data->[0]}, (split(/-/,$s))[0];
      $data->[$y][$#{$data->[0]}] = $stats_data->{$s}{$_};
      #print "$s\t$_\t$stats_data->{$s}{$_}\n";
    }
  }
}

##
## creates a xy points graph
##
sub plot_stats($$) {

    my ($legend_ref,$png_fh) = @_;
    my $points_graph = GD::Graph::points->new(800, 500);

    $points_graph->set(
		     x_label       => '1-specificity',
		     y1_label      => 'sensitivity',
		     title         => 'True Positive vs False Positive Rates',
		     x_tick_number => 'auto',
		     marker_size   => 2,
		     legend_placement => 'BC',
		     y_max_value   => 1,
		     y_min_value  => 0
		     ) or warn $points_graph->error;
    $points_graph->set(dclrs => [('lred'),('lblue')]);
    $points_graph->set( markers => [1, 5] );
    $points_graph->set_legend(@$legend_ref);
    _print_graph($points_graph,$png_fh);
}
1;
