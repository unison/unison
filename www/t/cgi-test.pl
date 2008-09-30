#!/usr/bin/env perl
# cgi-test -- test Unison cgis
# You must be sitting in the CGI directory you wish to test.

use warnings;
use strict;

use Benchmark ':hireswallclock';
use Getopt::Long;

use lib '../../perl5-ext';
use Term::ANSIScreen qw/:color/;

my @badwords = ( 'Server Error', 'Object not found', 'DBIError', 'Exception',
    'Error' );

my %opts = (
			verbose => 0,
			pseq_id => 76,
			html    => ( defined $ENV{HTTP_HOST} ? 1 : 0 ),

			# hardcoded "options" (er, I guess those aren't really options)
			hmm_params_id => 55,
			pfam_ls_pmodelset_id => 31,
);

my $usage = <<'EOU';
#-------------------------------------------------------------------------------
# NAME    : page_test
# PURPOSE : test cgi scripts under Unison web tree
# USAGE   : page_test OPTIONS
# OPTIONS :
#       -h  <host>    # unison host machine name
#       -db <dbname>  # database name to connect to
#       -q  <pseq_id> # pseq_id commonly used for testing
#       -v            # verbose option to see the commnd line used for testing
#------------------------------------------------------------------------------
EOU

GetOptions( \%opts, 'verbose|v', 'query|q=i', 'dbname|db=s', 'host|h=s',
    'help' )
    || die("$0: Incorrect Usage\n");

die "$usage" if ( $opts{help} );    # should use Pod::Usage



my $PASS
    = $opts{html}
    ? '<font color="green">PASSED</font>'
    : colored( 'PASSED', 'green' );
my $FAIL
    = $opts{html}
    ? '<font color="red">FAILED</font>'
    : colored( 'FAILED', 'red' );

my %ignored_scripts = map { $_=> 1 } qw(
										 ../compare_methods.pl
										 ../compare_scores.pl
										 ../emb_search_category.pl
										 ../emb_search_form.pl
										 ../emb_search_query.pl
										 ../search_features.pl
										 ../unison-domain-graphic.sh
										 ../LICENSE
										 ../Makefile
										 ../av
										 ../bin
										 ../cgi
										 ../credits.html
										 ../critical-tables.pdf
					                                         ../doc
					                                         ../dumps
										 ../hardware-failure.html
										 ../index.html
										 ../js
										 ../license.html
										 ../more.html
										 ../offline.html
										 ../search2.pl
										 ../searchplugin
										 ../shots.html
										 ../styles
										 ../tmp
										 ../topnav.html
										 ../tour
										 ../unison-tutorial.pdf
									  );

my %dir_scripts = ( map { $_ => 1 }
					grep { not m%(?:CVS|t|~)$%
							 and not exists $ignored_scripts{$_} }
					glob('../*') );

my @cgi_scripts =
  (
   [ './env.sh' ],

   #### About
   [ '../about.pl' ],
   [ '../contents.pl' ],
   [ '../credits.pl' ],
   [ '../doc.pl' ],
   [ '../env.pl' ],
   [ '../getting.pl' ],
   [ '../index.pl' ],
   [ '../license.pl' ],
   [ '../prefs.pl' ],
   [ '../shots.pl' ],
   [ '../stats.pl' ],

   #### Browse
   [ '../browse_top.pl' ],
   [ '../browse_sets.pl',  "pset_id=-1234" ],
   [ '../browse_sets.pl',  "pset_id=1047" ],
   [ '../browse_views.pl', "cv_id=4" ],
   #### Search
   [ '../search_top.pl' ],
   [ '../search_alias.pl', "alias=EGFR_HUMAN" ],
   ['../search_framework.pl'],
   [ '../search_properties.pl',
	 "o_sel=RefSeq r_species=on r_species_sel=9606 r_age_sel=30d r_len=on r_len_min=100 r_len_max=400 r_sigp=on r_sigp_sel=0.6 al_hmm_eval=1e-10 al_pssm_eval=1e-10 al_prospect=on al_prospect_svm=9 al_prospect_params_id=1 al_ms_sel=2 al_go_sel=5164 x_set_sel=5 submit=submit"
   ],

   #### Sequence analysis
   [ '../pseq_top.pl' ],
   [ '../pseq_annotations.pl', "pseq_id=$opts{pseq_id}" ],
   [ '../pseq_features.pl',   "pseq_id=$opts{pseq_id}" ],
   [ '../pseq_functions.pl',  "pseq_id=$opts{pseq_id}" ],
   [ '../pseq_history.pl',    "pseq_id=$opts{pseq_id}" ],
   [ '../pseq_homologs.pl',   "pseq_id=$opts{pseq_id}" ],
   [ '../pseq_intx.pl',       "pseq_id=94893" ],
   [ '../pseq_loci.pl',       "pseq_id=$opts{pseq_id}" ],
   [ '../pseq_notes.pl',      "pseq_id=231" ],
   [ '../pseq_pahmm.pl',      "pseq_id=$opts{pseq_id}" ],
   [ '../pseq_paprospect.pl', "pseq_id=$opts{pseq_id}" ],
   [ '../pseq_papssm.pl',     "pseq_id=$opts{pseq_id}" ],
   [ '../pseq_patents.pl',    "pseq_id=$opts{pseq_id}" ],
   [ '../pseq_similarity.pl', "pseq_id=$opts{pseq_id}" ],
   [ '../pseq_structure.pl',
	 "pseq_id=870 userfeatures=mysnp\@931 highlight=user:mysnp:cyan,HMM:Furin-like:blue"
   ],
   [ '../pseq_summary.pl', "pseq_id=$opts{pseq_id}" ],

   #### Tools
   [ '../tools_top.pl' ],
   [ '../alian.pl' ],
   [ '../babelfish.pl' ],
   [ '../on_target.pl',
	 "submit=submit pset_id=5 pmodelset_id=3 hmm=on hmm_params_id=15 hmm_eval=1e-10 pssm=on pssm_params_id=8 pssm_eval=1e-10 prospect=on prospect_params_id=1 prospect_svm=12"
   ],
   # ['../compare_methods.pl',"submit=submit pmodelset_id=3 pcontrolset_id=500 params_id=1 score=raw"],
   # ['../compare_scores.pl',"submit=submit pmodelset_id=3 pcontrolset_id=500 params_id=1 score=svm Plot=Scatter"],
   # ['../compare_scores.pl',"submit=submit pmodelset_id=3 pcontrolset_id=500 params_id=1 score=svm Plot=Range"],
   # ['../compare_scores.pl',"submit=submit pmodelset_id=3 pcontrolset_id=500 params_id=1 score=svm Plot=Clustered"],
   # ['../compare_scores.pl',"submit=submit pmodelset_id=13 pcontrolset_id=500 params_id=1 score=raw Plot=Scatter"],
   # ['../compare_scores.pl',"submit=submit pmodelset_id=13 pcontrolset_id=500 params_id=1 score=raw Plot=Range"],
   # ['../compare_scores.pl',"submit=submit pmodelset_id=13 pcontrolset_id=500 params_id=1 score=raw Plot=Clustered"],

   #### Embedable components
   [ '../emb_genome_map.pl',
	 'genasm_id=2 chr=6 gstart=31646498 gstop=31658288 params_id=32'
   ],
   [ '../emb_hmm_alignment.pl',
	 "pseq_id=98 params_id=$opts{hmm_params_id} profiles=TNF pmodelset_id=$opts{pfam_ls_pmodelset_id}"
   ],
   [ '../emb_pseq_structure.pl',
	 "pseq_id=98 userfeatures=Estrand\@164-174,mysnp\@170 highlight=user:Estrand:green,user:mysnp:cyan,HMM:TNF:blue"
   ],

   #### Miscellanea
   [ '../hmm_alignment.pl',
	 "pseq_id=$opts{pseq_id} profiles=TNF params_id=$opts{hmm_params_id} pmodelset_id=$opts{pfam_ls_pmodelset_id}"
   ],
   [ '../p2alignment.pl', "pseq_id=76 params_id=1 templates=1jtzx" ],
   [ '../p2cm.pl',
	 "pseq_id=$opts{pseq_id} viewer=rasmol params_id=1 templates=1jtzx"
   ],
   [ '../chr_view.pl',     "chr=3 gstart=173540198 gstop=173567087" ],
   [ '../genome_features.pl',
	   "genasm_id=2 chr=15 gstart=39562512 gstop=39591527 params_id=32"
   ],
   [ '../get_fasta.pl', "pseq_id=$opts{pseq_id}" ],
   [ '../nph-pdb-fetch.sh', '1jtz' ],
   [ '../search.pl' ],

   #### Redirects
   [ '../pseq_blast.pl' ],
   [ '../pseq_paliases.pl' ],
  );


select(STDERR); $|++;
select(STDOUT); $|++;

if ( $opts{html} ) {
    print <<EOT;
Content-type: text/html

<html><body><pre>
EOT
}


my $npassed = 0;

print( '$Id$ ', "\n\n" );

printf( "%-30.30s\tstatus\t%7s\tmessage\n", 'script', 'time' );
print( '=' x 76, "\n" );
foreach my $cgi (@cgi_scripts) {
    my $message = '';
    my $failed  = 0;
    delete $ENV{QUERY_STRING};

    if ( defined $cgi->[1] ) {
        ( $ENV{QUERY_STRING} = $cgi->[1] ) =~ s/ /;/g;
    }
    my $cmd = $cgi->[0];
    if ( not $opts{html} and $cgi->[0] ne '../nph-pdb-fetch.sh' ) {
        $cmd .= " host=$opts{host} dbname=$opts{dbname}";
    }
    $cmd .= " $cgi->[1]" if ( defined $cgi->[1] );
    delete $dir_scripts{ $cgi->[0] };
    printf( '%-30.30s', $cgi->[0] . ' ' . '.' x 30 );

    my $t0     = new Benchmark;
    my $output = `$cmd 2>&1`;

    if ($?) {
        $message = $!;
        $failed++;
    }
    else {
        my $word;
        foreach $word (@badwords) {
            if (    $output =~ /\b$word\b/i
                and $output !~ /$word.pm/
                and $output !~ /REMARK/ )
            {
                $message = $&;
                if (   ( $word eq 'Exception' and $output =~ m/Detail.+/ )
                    or ( $word eq 'Error' and $output =~ m/Error:.+/ ) )
                {
                    $message = $&;
                }
                $failed++;
                last;
            }
        }
    }

    my $t1 = new Benchmark;
    my $time = @{ timediff( $t1, $t0 ) }[0];

    printf( "\t%s\t%6.1fs\t$message\n", ( $failed ? $FAIL : $PASS ), $time );
    if ($failed) {
        print <<EOT;
</pre>
<div style="background: pink; margin-left: 50px; overflow: auto; height: 15%;">
<b>command:</b> $cmd $ENV{QUERY_STRING}
<pre>
$output
</pre>
</div>
<pre>
EOT
    }
    $npassed++ unless $failed;
}

print( "\nTotal Passed = $npassed / ", $#cgi_scripts + 1, "\n" );

if ( scalar keys %ignored_scripts ) {
    print("\n");
    printf( "WARNING: %d scripts were ignored:\n",
        scalar keys %ignored_scripts );
    print("  $_\n") for sort keys %ignored_scripts;
}

if ( scalar keys %dir_scripts ) {
    print("\n");
    printf( "WARNING: %d scripts were not tested:\n",
        scalar keys %dir_scripts );
    print("  $_\n") for sort keys %dir_scripts;
}

# print( "\nEnvironment:\n", `env|sort`, "\n" );

if ( $opts{html} ) {
    print <<EOT;
</pre></body></html>
EOT
}
