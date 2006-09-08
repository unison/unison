#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../perl5", "$FindBin::Bin/../perl5-prereq", "$FindBin::Bin/../../perl5";

use Unison::SQL;
use Unison::WWW;
use Unison::WWW::Page;
use Unison::WWW::Table;

my $p = new Unison::WWW::Page;
my $u = $p->{unison};
$p->add_footer_lines('$Id: browse_views.pl,v 1.17 2006/08/17 17:27:05 rkh Exp $ ');

my %cvs = %{ $u->selectall_hashref('select cv_id,name,descr,sql,order_by from canned_views',
								   'cv_id') };

print $p->render('Canned Views',
				 build_form($p),
				 do_search($p)
				);

exit(0);


######################################################################

# It would be much better to get these descriptions from the database
# view column comments...

sub do_search {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();

  my %coldescr = (
				  # I'd love to be fetching these from the column comments...
				  'pseq_id' => 'Unison unique sequence identifier',
				  'TM' => 'number of transmembrane domains',
				  'pat' => 'is this (exact) sequence patented?',
				  'pat98' => 'is this sequence within 98% of a patented
                            sequence? (not including the sequence itself)',
				  'eval' => 'HMM expectation value',
				  'Ig' => 'start and end of the Ig domain',
				  'ITIM' => 'start and end of the ITIM domain',
				  'alias' => 'Unison sequence annotation',
				  'gs' => 'genus and species',
				  'descr' => 'sequence description',
				  'tm_prob' => 'TM region prediction probability',
				  'best_annotation' => 'Best annotations are
					   a guess about the most informative and reliable
					   annotation for this sequence from all source
					   databases.'
				 );

  return '' unless defined $v->{cv_id};

  my $cv = $cvs{$v->{cv_id}};

  my $s_sql = Unison::SQL->new()
	->table( "($cv->{sql}) X" );

  if (exists $v->{r_species}) {
	$s_sql
	  ->join('palias A on X.pseq_id=A.pseq_id' )
	  ->where("A.tax_id=$v->{r_species_sel}");
  }

  if (exists $v->{r_age} or exists $v->{a_added}) {
	$s_sql->join('pseq Q on X.pseq_id=Q.pseq_id');
	$s_sql->where("Q.added >= now()-'$v->{r_age_sel}'::interval") if exists $v->{r_age};
  }

  # column order
  # FIXME: genasm_id=3 and params_id=45 shouldn't be hardwired
  # consider 1-arg versions of these for most recent human alignment
  $s_sql->columns('pseq_locus(X.pseq_id,3,45) as locus') if ($v->{a_locus});
  $s_sql->columns('best_alias(pseq_locus_rep(X.pseq_id,3,45)) as locus_rep') if ($v->{a_locus_rep});
  $s_sql->columns('best_annotation(X.pseq_id)') if ($v->{a_best_annotation});
  $s_sql->columns('X.*');
  $s_sql->columns('Q.added::date') if ($v->{a_added});
  $s_sql->columns("(select as_set(distinct 'UNQ'||unqid) from gg_unq_pro_dna_pseq_v where pseq_id=X.pseq_id group by unqid order by unqid) as unqs") if ($v->{a_unq});
  $s_sql->columns("(select as_set(distinct 'PRO'||proid) from gg_unq_pro_dna_pseq_v where pseq_id=X.pseq_id group by proid order by proid) as pros") if ($v->{a_pro});
  $s_sql->columns("(select as_set(distinct(chip||':'||probe_id)) from pseq_probe_v P where P.pseq_id=X.pseq_id) as probes") if ($v->{a_probes});

  if ($v->{a_locus_rep} eq 'order') {
	$s_sql->order('locus_rep');
  } elsif ($v->{a_locus_rep} eq 'distinct') {
	$s_sql->distinct('locus_rep');
  }

  my $sql = "select * from ($s_sql) Y";
  $sql .= " ORDER BY $cv->{order_by}" if (defined $cv->{order_by});

  my $sth = $u->prepare( $sql );
  my $ar = $u->selectall_arrayref($sth);
  my @cols = @{ $sth->{NAME} };

  for (my $i=0; $i<=$#cols; $i++) {
	if ($cols[$i] eq 'pseq_id') {
	  foreach my $row (@$ar) {
		$row->[$i] = "<a href=\"pseq_summary.pl?pseq_id=$row->[$i]\">$row->[$i]</a>";
	  }
	} elsif ($cols[$i] =~ /^pat/) {
	  foreach my $row (@$ar) {
		$row->[$i] = $row->[$i] ? 'yes' : '';
	  }
	} elsif ($cols[$i] =~ /^probes/) {
	  foreach my $row (@$ar) {
		next unless defined $row->[$i];
		my @elems = split(/,/,$row->[$i]);
		my @links;
		for (my $elems_i=0; $elems_i<=$#elems; $elems_i++) {
		  my ($chip,$probe) = $elems[$elems_i] =~ m/(\w+):(\w+)/;
		  push(@links,"<a target=\"_blank\" href=\"http://research/projects/maprofile/bin/secure/maprofile.cgi?probeid=$probe\">$elems[$elems_i]</a>");
		}
		$row->[$i] = join('<br>',sort @links);
	  }
	} elsif ($cols[$i] =~ /unqs/) {
	  foreach my $row (@$ar) {
		next unless defined $row->[$i];
		my @elems = split(/,/,$row->[$i]);
		my @links;
		for (my $elems_i=0; $elems_i<=$#elems; $elems_i++) {
		  push(@links,"<a target=\"_blank\" href=\"http://research/projects/gg/jsp/UNQ.jsp?UNQID=$elems[$elems_i]\">$elems[$elems_i]</a>");
		}
		$row->[$i] = join('<br>',sort @links);
	  }
	}
  }

  my @colhdrs = map {$p->tooltip($_,$coldescr{$_})} @cols;
  return( "<hr>\n",
		  "<b>$cv->{name} (view $cv->{cv_id})</b>: <i>$cv->{descr}</i>",
		  $p->group(sprintf("%s; %d rows",$cv->{name}, $#$ar+1),
					Unison::WWW::Table::render(\@colhdrs,$ar)),
		  $p->sql("$sql")
		);
}




my %defaults = 
  (
   cv_id => undef,
   r_species => 'off',
   r_species_sel => 9606,
   r_age => 'off',
   r_age_sel => 30,
   a_added => 'off',
   a_locus => 'off',
   a_best_annotation => 'on',
   a_probes => 'off',
   a_locus_rep => 'no',
   a_unq => 'no',
   a_pro => 'no',
   a_fam => 'no'
  );

sub build_form {
  my $p = shift;
  my $u = $p->{unison};
  my $v = $p->Vars();

  my @cvs = sort {$a<=>$b} keys %cvs;
  # restrict menu to cv_id>0 unless a cv_id<0 is being displayed (usually power users)
  @cvs = grep {$_>0} @cvs  unless (defined $v->{cv_id} and $v->{cv_id}<0);

  my %cvlabels = map {$_ => sprintf("%s (canned view %d)",$cvs{$_}->{name}, $_)} @cvs;

  my %sl = map { $_->[0] => "$_->[1] ($_->[3]; $_->[2])" } 
	@{ $u->selectall_arrayref("select tax_id,common,latin,gs from tax.spspec
                               where tax_id in (7955,9606,10090,10116,10117,
                                                9615,9685,7227)
                               order by gs") };


  return (
		  $p->warn('"Canned" queries on this page may be
				 computationally expensive and take several minutes to
				 complete. Please be patient and click submit only once.'),

		  $p->start_form(-method => 'GET'),

		  # SELECTION
		  '<table width="100%">',
		  '<tr>',
		  '<td>Show</td><td>',
		  $p->popup_menu(-name=>'cv_id',
						 -values => \@cvs,
						 -labels => \%cvlabels,
						 -default => $v->{cv_id}
						),
		  '</td></tr>',
		  '<tr><td colspan=2>where:</td></tr>',
		  '<tr><td>',
		  $p->checkbox(-name => 'r_species',
					   -label => 'species is',
					   -checked => $v->{r_species}||$defaults{r_species}),
		  '</td><td>',
		  $p->popup_menu(-name => 'r_species_sel',
						 -values => [sort keys %sl],
						 -labels => \%sl,
						 -default => $v->{r_species_sel}||$defaults{r_species_sel}
						),
		  '</td></tr>',
		  '<tr><td>',
		  $p->checkbox(-name => 'r_age',
					   -label => 'sequence is less than',
					   -checked => $v->{r_age}||$defaults{r_age}),
		  '</td><td colspan=2>',
		  $p->popup_menu(-name=>'r_age_sel',
						 -values=>[qw(7 14 30 60 90 180 365)],
						 -default=>$v->{r_age_sel}||$defaults{r_age_sel}
						),
		  ' days old',
		  '</td></tr>',
		  '</table>',


		  # ANNOTATIONS
		  '<table width="100%">',
		  '<tr><td colspan=3><u>Additional Annotation</u></td></tr>',
		  '<tr>',
		  '<td valign="top">',
		  $p->checkbox(-name => 'a_added',
					   -label => 'date sequence added',
					   -checked => $v->{a_added}||$defaults{a_added}),
		  '<br>',
		  $p->checkbox(-name => 'a_locus',
					   -label => 'Human genomic locus',
					   -checked => $v->{a_locus}||$defaults{a_locus}),
		  '<br>',
		  $p->checkbox(-name => 'a_best_annotation',
					   -label => '"best" annotation',
					   -checked => $v->{a_best_annotation}||$defaults{a_best_annotation} ),
		  '<br>',
		  $p->checkbox(-name => 'a_probes',
					   -label => 'microarray probes',
					   -checked => $v->{a_probes}||$defaults{a_probes}),
		  '</td>',
		  '<td style="vertical-align: top;">',
		  'Genomic Representative:<br>',
		  $p->radio_group(-name => 'a_locus_rep',
						  -label => 'name of best genomic locus representative sequence',
						  -values => ['no', 'yes', 'order', 'distinct'],
						  -labels => { no => 'no',
									   'yes' => 'just the name, preserve results order',
									   'order' => 'order (group) by representative',
									   'distinct' => 'order hits by distinct representative' },
						  -default => $v->{a_locus_rep}||$defaults{a_locus_rep},
						  -linebreak => 'true'
						  ),
		  '</td>',
		  '<td style="vertical-align: top;">',
		  'Genentech Annotations:<br>',
		  $p->checkbox(-name => 'a_unq',
					   -label => 'UNQ',
					   -checked => $v->{a_unq}||$defaults{a_unq}),
		  '<br>',
		  $p->checkbox(-name => 'a_pro',
					   -label => 'PRO',
					   -checked => $v->{a_pro}||$defaults{a_pro}),
		  '<br>',
		  '</td>',
		  '</tr>',
		  '</table>',

		  $p->submit(-value=>'submit'),
		  $p->end_form(), "\n",
		 )
};
