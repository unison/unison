#!/bin/sh
# 
# Simple test script which ensures that errors get sent to the browser
# This should eventually be replaced by a more general test harness for
# arbitrary scripts.
#

echo "Content-type: text/plain"
echo

exec `dirname $0`/about_env.pl  2>&1
