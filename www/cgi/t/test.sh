#!/usr/bin/env perl

print "Content-type: text/plain"
print

exec `dirname $0`.'/../'.`basename $0`;
