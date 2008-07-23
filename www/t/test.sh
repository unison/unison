#!/bin/sh
# test.sh -- CGI test harness
#
# usage: Symlink this file, test.sh, to the name of any cgi in ../.  When
# invoked as a CGI, it will merge stderr to stdout and exec the "real"
# script by the same name in ../ .
#
# Example:
# $ cd t
# $ ln -fns test.sh pseq_summary.pl
# Then load ../unison/t/pseq_summary.pl?q=7
# You'll see the raw HTML and errors in a web page.
#

# 
exec 2>&1

echo "Content-type: text/plain"
echo

E="../`basename $0`";

echo "$E"

if [ -e "$E" -a -x "$E" ]; then
		exec "$E"
fi

echo "Couldn't find $E!"

