package Unison::compare_scores;
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
use Cluster;

sub get_p2_scores($$);
sub get_scop_pdb($);
sub display_points($);
sub display_bars($);
sub display_table();

my %params =
 (
  nclusters => 4,
  algorithm => "kcluster",
  associate => ['white','yellow','blue','red','grey'] # in the order of increasing scores
  );

my $scopURL = 'http://scop.berkeley.edu/search.cgi?sunid=';
my $pdbURL = 'http://www.rcsb.org/pdb/cgi/explore.cgi?pdbId=';

my ($pmodel_scop,$pmodel_pdb);
my ($scores,$sp,$data);

##
## 1. get pseqs,pmodels of pmodelset
## 2. get pseqs of universal_seq_set (pset_id=52)
## 3. subtract pseqs from universal_set_pseqs
## 4. set the $scores hash in this form:
## {model}{sequence} => score
##

sub get_p2_scores($$) {

  my ($u,$v) = @_;
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
	  ->columns($params{score})
	    ->columns('pmodel_id')
	      ->columns('pseq_id')
		->where('pseq_id in (' . join(',',@univ) . ')')
		  #the 0 x 100 is a hack to force PG to choose a better execution plan!
		  ->where('pmodel_id in (' . join(',',(values %ms, (0) x 100)) . ')');

      my @sc = @{ $u->selectall_arrayref("$sql") };
      map {$$scores{$_->[1]}{$_->[2]} = $_->[0]} @sc;
    }
    foreach my $i (keys %$scores) {
      $$scores{$i}{'0'}=undef;
    }
  return ($scores);
}

##
##Reorganize hash suitable for GD::Graph ploting
##X labels in first row and their values in subsequent rows
##and then plot
##
sub display_points($) {

  my ($png_fh) = @_;
  my ($cols,$rows,$temp,$imagerefs,$labelrefs);

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
    push @$data, $row;#scores for each pseq with this model
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
  $points_graph->set_legend_font(GD::Font->MediumBold);
  _print_graph($points_graph,$png_fh);

  #create an imagemap for the graph
  my $map = new GD::Graph::Map($points_graph,
			    hrefs=>$imagerefs,
			   lhrefs=>$labelrefs,
        noImgMarkup=>1,
        mapName=>"scattermap",
        info => 'pseq= %x,  model = %l, score = %y'
    );
  return $map;
}

sub display_bars($) {

  my ($png_fh) = @_;
  my ($cols,$temp,$mins,$maxs,$err_mins,$err_maxs,$err_meds);

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
    }
  }
  push @$data,$mins;
  push @$data,$maxs;
  push @$data,$err_mins;
  push @$data,$err_maxs;
  push @$data,$err_meds;
  _plot_bars($png_fh);
}


##
## creates an error-bar style graph
##
sub _plot_bars {

  my ($png_fh) = @_;
  my $bar_graph = GD::Graph::mixed->new(800, 500);

  $bar_graph->set(	
		types         => ['bars','bars','bars','bars','points'],
		x_label       => 'Sequence_ids',
		y_label       => $params{score}." score",
		title         => 'Scoring Range for known and Known-NOT sequences against known Models',
		markers       => [1],
		marker_size   => 1,
		x_label_skip  => ($#{$$data[0]}/20)+1,#skipping a label for every 20, X values.
		x_all_ticks   => 1,
		y_tick_number => 10,
		cumulate      => 1,
		error_bars    => 1,
	       ) or warn $bar_graph->error;
  $bar_graph->set(dclrs => [('','blue','','lred','green')]);
  _print_graph($bar_graph,$png_fh);
}


## writes png image to a temp file
sub _print_graph {

  my($mygraph,$png_fh) = @_;

  $mygraph->set_x_label_font(GD::Font->MediumBold);
  $mygraph->set_y_label_font(GD::Font->MediumBold);
  $mygraph->set_x_axis_font(GD::Font->Small);
  $mygraph->set_y_axis_font(GD::Font->Small);
  $mygraph->set_title_font(GD::Font->Giant);
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

sub display_table {

  my ($cols,$rows);
  my $c = Cluster::new(%params);
  my $cluster_arr = $c->cluster_2dhash($scores);
  return "CLUSTERING OF THREADING SCORES FAILED!" if(!defined($cluster_arr));

  my $ret = '<table border=1><tr>';
  $ret .= '<th>seq/model</th>';

  push @$cols, keys %$scores;
  foreach (keys %$scores) {
    my $link = $_;
    if(exists($$pmodel_scop{$_})) {
      $link =  "<a href=\"$scopURL$$pmodel_scop{$_}{'sunid'}\">$$pmodel_scop{$_}{'name'}</a>";
    }
    else {
      $link =  "<a href=\"$pdbURL".substr($$pmodel_pdb{$_},0,4)."\">$$pmodel_pdb{$_}</a>";
    }
    $ret .= '<th>'.$link.'</th>';#models on first row
  }

  foreach my $i(sort {$$sp{$a} <=> $$sp{$b}} keys %$sp) {
    if(exists($$scores{$$cols[0]}{$i})) {

      my $link = "<a href=\"pseq_summary.pl?pseq_id=$i\">$i</a>";
      $ret .= '</tr><tr><th>'.$link.'</th>';#first col in each row is a pseq link

      foreach my $j(keys %$scores) {
	my $order = ($params{score} eq 'raw' ? -1 : 1);
	my $clr = $c->get_association($$scores{$j}{$i},$order);
	$ret .= sprintf("<th bgcolor=%s>%2.1f</th>",$clr,$$scores{$j}{$i}) if(defined($$scores{$j}{$i}));
      }
    }
  }
  $ret .= '</tr></table>';
  return $ret;
}


sub get_scop_pdb($) {

  my ($u) = @_;

  my @pm_scop = @{ $u->selectall_arrayref('select pmodel_id,sp,pdb from mukhyala.v_scop_pmodel where pmodel_id in  (' . join(',',keys %$scores) . ') order by pmodel_id') };

  map {$$pmodel_scop{$_->[0]}{'sunid'} = $_->[1]} @pm_scop;
  map {$$pmodel_scop{$_->[0]}{'name'}  = $_->[2]} @pm_scop;

  my @pm_pdb = @{ $u->selectall_arrayref('select pmodel_id,acc from pmprospect2 where pmodel_id in  (' . join(',',keys %$scores) . ') order by pmodel_id') };

  map {$$pmodel_pdb{$_->[0]} = $_->[1]} @pm_pdb;
}

1;
