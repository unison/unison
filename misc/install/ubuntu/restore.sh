#!/bin/sh
# restore.sh -- restore a unison database

V=20090831

PS4='+(\u) '
set -x

createuser -D -A -R PUBLIC
createuser -D -A -R genengenes
createuser -D -A -R loader
createuser -D -A -R mathejb
createuser -D -A -R mukhyala
createuser -D -A -R postgres	# fail ok if cluster installed as postgres
createuser -D -A -R rkh
createuser -D -A -R unison


#dropdb unison-$V
createdb -E UTF-8 unison-$V
createlang -d unison-$V plpgsql
createlang -d unison-$V plperl

gzip -cd <unison-$V.sql.gz | psql -qaf-

