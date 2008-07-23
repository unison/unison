#!/usr/bin/perl

use CGI qw( redirect );
print redirect( -uri => 'pseq_summary.pl?' . $ENV{QUERY_STRING},
				-status => 302 );
exit(0);
