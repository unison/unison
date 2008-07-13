#!/usr/bin/perl

use CGI qw( redirect );
print redirect( -uri => 'pseq_similarity.pl?' . $ENV{QUERY_STRING},
				-status => 301 );
exit(0);
