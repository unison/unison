#!/usr/bin/env perl

use strict;
use warnings;
use Unison::WWW;
use Unison::WWW::Page qw(infer_pseq_id);
use Unison::WWW::Table;
use Unison::WWW::utils qw(alias_link pseq_summary_link);
use Unison::pseq_features;
use File::Temp qw(tempfile);


my $p = new Unison::WWW::Page();
my $u = $p->{unison};
my $v = $p->Vars();

$p->ensure_required_params( qw( pseq_id ) );


my $sql = qq/select O.origin,AO.alias,AO.descr from pseqalias SA
      join paliasorigin AO on AO.palias_id=SA.palias_id
      join porigin O on O.porigin_id=AO.porigin_id
      where SA.pseq_id=$v->{pseq_id} and SA.iscurrent=true and O.ann_pref<=10000 
      order by O.ann_pref/;
my $ar = $u->selectall_arrayref($sql);
do { $_->[1] = alias_link($_->[1],$_->[0]) } for @$ar;
my @f = qw( origin alias description );

my $seq = $u->get_sequence_by_pseq_id($v->{pseq_id});
my $wrapped_seq = $seq; $wrapped_seq =~ s/.{60}/$&\n/g;

$sql = qq/select b.pseq_id,best_alias(b.pseq_id),tax_id2gs(b.tax_id) from homologene a, 
  homologene b where a.pseq_id=$v->{pseq_id} and b.hid=a.hid and b.pseq_id!=a.pseq_id 
  order by 3,1/;
my $or = $u->selectall_arrayref($sql);
do { $_->[0] = pseq_summary_link($_->[0],$_->[0]) } for @$or;



my ($png_fh, $png_fn) = File::Temp::tempfile(DIR => "$ENV{'DOCUMENT_ROOT'}/tmp/pseq-features/",
                       SUFFIX => '.png' );
my ($urn) = $png_fn =~ m%^$ENV{'DOCUMENT_ROOT'}(.+)%;
$png_fh->print( $u->features_graphic($v->{pseq_id}) );
$png_fh->close( );


print $p->render("Summary of Unison:$v->{pseq_id}",
         $p->best_annotation($v->{pseq_id}),

         '<p>',
         $p->group(sprintf("Sequence (%d&nbsp;AA)", length($seq)),
               '<pre>', 
               '&gt;Unison:', $v->{pseq_id}, ' ', $u->best_alias($v->{pseq_id},1), "\n",
               $wrapped_seq,
               '</pre>' ),

         '<p>',
         $p->group(sprintf('%s (%d)',
						   $p->tooltip('Aliases', 'Unison stores sequences
						   non-redundantly from many sources. Aliases are
						   all of the known names for this exact
						   sequence.'),
						   $#$ar+1),
               'These are the aliases from the most reliable sources only; see also ',
               '<a href="pseq_paliases.pl?pseq_id=', $v->{pseq_id}, '">other aliases</a><p>',
               Unison::WWW::Table::render(\@f,$ar)),

         '<p>',
         $p->group(sprintf('<a href="http://www.ncbi.nlm.nih.gov/entrez/query.fcgi?db=homologene">Homologene</a> (%d)',$#$or+1),
               Unison::WWW::Table::render(['pseq_id','alias','genus/species'],$or)),

         '<p>',

         $p->group($p->tooltip('Features','precomputed results for this
						   sequence. NOTE: Not all sequences have all
						   results precomputed -- see the History tab to
						   determine which analysis have been performed'),
               "<center><img src=\"$urn\"></center>")
        );
