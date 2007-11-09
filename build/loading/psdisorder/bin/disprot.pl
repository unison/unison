#!/usr/bin/perl
# disprot -- submit sequence to disprot web service

use strict;
use warnings;
use LWP::UserAgent;
use IO::File;
use Bio::SeqIO;
use Getopt::Long qw(:config gnu_getopt);
use Data::Dumper;
use HTTP::Headers;

my $disprot_host = 'www.ist.temple.edu';

my %opts = (
    ssh_proxy => undef,
    nowarn    => 0,
    predictor => 'vl3h',                            # vl2, vl3, vl3e
    window    => 1,                                 # 1, 11, 21, .., 121
    sleep     => 120,
    host      => $disprot_host,
    port      => 80,
    rel_url   => '/disprot/predictor_action.php',
);

GetOptions(
    \%opts,

    #		'ssh_proxy|S=s',
    'nowarn+',
    'predictor|P=s',
    'window|w=i',
    'sleep|s=i',
    'host|h=s',
    'port|p=i',
) || die("$0: bad option\n");

my $url = "http://$opts{host}:$opts{port}$opts{rel_url}";

print( STDERR <<EOT);
# url=$url
# predictor=$opts{predictor}
# window=$opts{window}
# sleep=$opts{sleep}
EOT

die(<<EOT) unless $opts{nowarn};
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!! WARNING: add --nowarn to acknowledge that you're about to !!
!! send sequences outside Genentech.                         !!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
EOT

my $pd_re
    = qr%<tr>\s*\n\s+<td>\d+</td>\s*\n\s+<td>\w</td>\s*\n\s+<td>(\d\.\d+)</td>\s*\n\s+</tr>%;

my %form_fields = (
    sequence  => undef,
    predictor => $opts{predictor},
    window    => $opts{window},

    #   email => undef,							# optional except for vl3e
    submit => 'Submit'
);

my $ua = LWP::UserAgent->new(
    agent => 'disprot-commandline/0.0',
    from  => 'Reece Hart <rkh@gene.com>',
);
my $req = HTTP::Request->new( POST => $url );
$req->content_type('application/x-www-form-urlencoded');

my $in = new Bio::SeqIO( -format => 'fasta', -fh => \*STDIN );
while ( my $bs = $in->next_seq() ) {
    my $id = $bs->display_id();
    my %input = ( %form_fields, sequence => $bs->seq() );
    $req->content( join( '&', map {"$_=$input{$_}"} keys %form_fields ) );
    my $res = $ua->request($req);
    if ( $res->is_success ) {
        if ( $res->content =~ m/You have exceeded/ ) {
            die("Prediction limit reached -- no more predictions today\n");
        }

        my (@pd) = $res->content =~ m/$pd_re/g;
        if ( length( $bs->seq() ) != $#pd + 1 ) {
            die(sprintf(
                    "$id: Yikes! sequence length (%d) != number of disorder probs (%d)!\n%s",
                    length( $bs->seq() ),
                    $#pd + 1
                )
            );
        }
        print("$id @pd\n");
    }
    else {
        print $res->status_line, "\n";
    }
}

