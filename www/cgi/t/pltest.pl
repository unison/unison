#!/usr/bin/perl

print <<EOF;
Content-type: text/plain

EOF

print("$_: $ENV{$_}\n") for sort ( keys %ENV );

exit(0);
