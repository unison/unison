#!/bin/sh

echo "Content-type: image/png"
echo

q=${QUERY_STRING}

D=`dirname $0`
exec $D/../../tools/bin/unison-domain-graphic --legend -w500 -U PUBLIC $q
