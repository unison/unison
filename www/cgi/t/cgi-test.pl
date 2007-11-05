#!/usr/bin/env perl
# cgi-test -- test Unison cgis
# You must be sitting in the CGI directory you wish to test.
# $Id: cgi-test.pl,v 1.18 2007/06/04 22:50:54 mukhyala Exp $

use warnings;
use strict;
use Getopt::Long;
use Benchmark ':hireswallclock';
use Term::ANSIScreen qw/:color/;

my %params = (
    hmm                  => 55,
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
# $Id: cgi-test.pl,v 1.18 2007/06/04 22:50:54 mukhyala Exp $
#------------------------------------------------------------------------------
EOU

my %opts = (
    verbose => 0,
    host    => 'csb',
    dbname  => 'csb-dev',
    pseq_id => 76,
    html    => ( defined $ENV{HTTP_HOST} ? 1 : 0 )
);

$ENV{PGHOST}     = $opts{host};
$ENV{PGDATABASE} = $opts{dbname};
$ENV{PGUSER}     = $opts{user} || 'PUBLIC';

GetOptions( \%opts, 'verbose|v', 'query|q=i', 'dbname|db=s', 'host|h=s',
    'help' )
  || die("$0: Incorrect Usage\n");

die "$usage" if ( $opts{help} );    # should use Pod::Usage

my $PASS =
  $opts{html}
  ? '<font color="green">PASSED</font>'
  : colored( 'PASSED', 'green' );
my $FAIL =
  $opts{html} ? '<font color="red">FAILED</font>' : colored( 'FAILED', 'red' );

select(STDERR);
$|++;
select(STDOUT);
$|++;

if ( $opts{html} ) {
    print <<EOT;
Content-type: text/html

<html><body><pre>
EOT
}

my $pseq_id = $opts{pseq_id};

my @cgi_scripts = (
    ['./env.sh'],
    ['../about_env.pl'],
    ['../about_origins.pl'],
    ['../about_params.pl'],
    ['../about_prefs.pl'],
    ['../about_statistics.pl'],
    ['../about_unison.pl'],
    [ '../browse_sets.pl',  "pset_id=-1234" ],
    [ '../browse_sets.pl',  "pset_id=1047" ],
    [ '../browse_views.pl', "cv_id=4" ],
    [ '../chr_view.pl',     "chr=3 gstart=173540198 gstop=173567087" ],

#   ['../compare_methods.pl',"submit=submit pmodelset_id=3 pcontrolset_id=500 params_id=1 score=raw"],
#   ['../compare_scores.pl',"submit=submit pmodelset_id=3 pcontrolset_id=500 params_id=1 score=svm Plot=Scatter"],
#   ['../compare_scores.pl',"submit=submit pmodelset_id=3 pcontrolset_id=500 params_id=1 score=svm Plot=Range"],
#   ['../compare_scores.pl',"submit=submit pmodelset_id=3 pcontrolset_id=500 params_id=1 score=svm Plot=Clustered"],
#   ['../compare_scores.pl',"submit=submit pmodelset_id=13 pcontrolset_id=500 params_id=1 score=raw Plot=Scatter"],
#   ['../compare_scores.pl',"submit=submit pmodelset_id=13 pcontrolset_id=500 params_id=1 score=raw Plot=Range"],
#   ['../compare_scores.pl',"submit=submit pmodelset_id=13 pcontrolset_id=500 params_id=1 score=raw Plot=Clustered"],
    [
        '../emb_genome_map.pl',
        'genasm_id=2 chr=6 gstart=31646498 gstop=31658288 params_id=32'
    ],
    [
        '../emb_hmm_alignment.pl',
"pseq_id=98 params_id=$params{hmm} profiles=TNF pmodelset_id=$params{pfam_ls_pmodelset_id}"
    ],
    [ '../nph-pdb-fetch.sh', '1jtz' ],
    [
        '../genome_features.pl',
        "genasm_id=2 chr=15 gstart=39562512 gstop=39591527 params_id=32"
    ],
    [ '../get_fasta.pl', "pseq_id=$pseq_id" ],
    [
        '../hmm_alignment.pl',
"pseq_id=$pseq_id profiles=TNF params_id=$params{hmm} pmodelset_id=$params{pfam_ls_pmodelset_id}"
    ],
    [ '../p2alignment.pl', "pseq_id=76 params_id=1 templates=1jtzx" ],
    [
        '../p2cm.pl',
        "pseq_id=$pseq_id viewer=rasmol params_id=1 templates=1jtzx"
    ],
    [ '../pseq_blast.pl',      "pseq_id=$pseq_id" ],
    [ '../pseq_features.pl',   "pseq_id=$pseq_id" ],
    [ '../pseq_history.pl',    "pseq_id=$pseq_id" ],
    [ '../pseq_loci.pl',       "pseq_id=$pseq_id" ],
    [ '../pseq_intx.pl',       "pseq_id=94893" ],
    [ '../pseq_notes.pl',      "pseq_id=231" ],
    [ '../pseq_pahmm.pl',      "pseq_id=$pseq_id" ],
    [ '../pseq_paliases.pl',   "pseq_id=$pseq_id" ],
    [ '../pseq_paprospect.pl', "pseq_id=$pseq_id" ],
    [ '../pseq_papssm.pl',     "pseq_id=$pseq_id" ],
    [ '../pseq_patents.pl',    "pseq_id=$pseq_id" ],
    [
        '../pseq_structure.pl',
"pseq_id=870 userfeatures=mysnp\@931 highlight=user:mysnp:cyan,HMM:Furin-like:blue"
    ],
    [
        '../emb_pseq_structure.pl',
"pseq_id=98 userfeatures=Estrand\@164-174,mysnp\@170 highlight=user:Estrand:green,user:mysnp:cyan,HMM:TNF:blue"
    ],
    [ '../pseq_summary.pl', "pseq_id=$pseq_id" ],
    [ '../search_alias.pl', "alias=EGFR_HUMAN" ],
    [
        '../search_properties.pl',
"o_sel=RefSeq r_species=on r_species_sel=9606 r_age_sel=30d r_len=on r_len_min=100 r_len_max=400 r_sigp=on r_sigp_sel=0.6 al_hmm_eval=1e-10 al_pssm_eval=1e-10 al_prospect=on al_prospect_svm=9 al_prospect_params_id=1 al_ms_sel=2 al_go_sel=5164 x_set_sel=5 submit=submit"
    ],
    ['../search_framework.pl'],
    [
        '../search_sets.pl',
"submit=submit pset_id=5 pmodelset_id=3 hmm=on hmm_params_id=15 hmm_eval=1e-10 pssm=on pssm_params_id=8 pssm_eval=1e-10 prospect=on prospect_params_id=1 prospect_svm=12"
    ],
);

# testing
# @cgi_scripts =
#  (
#   ['../pseq_features.pl',"pseq_id=$pseq_id"],
#  );

my %dir_scripts = map { $_ => 1 } grep { not m%(?:CVS|t|~)$% } glob('./* ../*');

my @badwords =
  ( 'Server Error', 'Object not found', 'DBIError', 'Exception', 'Error' );
my $npassed = 0;

print( '$Id: cgi-test.pl,v 1.18 2007/06/04 22:50:54 mukhyala Exp $ ', "\n\n" );

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

if ( scalar keys %dir_scripts ) {
    print("\n");
    printf( "WARNING: %d scripts were not tested:\n",
        scalar keys %dir_scripts );
    print("  $_\n") for sort keys %dir_scripts;
}

print( "\nEnvironment:\n", `env|sort`, "\n" );

if ( $opts{html} ) {
    print <<EOT;
</pre></body></html>
EOT
}
