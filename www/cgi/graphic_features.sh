#!/bin/sh
Q=`expr "${QUERY_STRING}" : 'pseq_id=\([0-9]*\)'`

echo "Content-type: image/png"
echo
exec /home/rkh/csb-db/unison/bin/graphic_features.pl -UPUBLIC -w600 -q$Q
