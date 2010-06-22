#!/bin/bash
# Installation on heart as reece (ie unpriv user)

if [ "$1 $2 $3" != "DESTROY MY DATA" ]; then
	echo "You must invoke as '$0 DESTROY MY DATA'" 1>&2
	exit 1
fi

#PATH=/lab/opt/postgresql/prd/x86_64-linux-2.6/bin:$PATH
#PGDATA=/scratch/reece/postgresql/8.4
PATH=/usr/lib/postgresql/8.4/bin:$PATH
PGDATA=/srv/postgresql/8.4

T=~reece

set -x

#$T/unison-db/dev/misc/config/berkeley/etc/init.d/postgresql-easy stop
/etc/init.d/postgresql stop

rm -fr "$PGDATA"

initdb -D "$PGDATA" -E UTF-8 --no-locale

cp -bv $T/unison-db/dev/misc/config/berkeley/postgresql/8.4/{postgresql.conf,pg_hba.conf} "$PGDATA"

rm -fr $T/logs/postgresql
mkdir -pv $T/logs/postgresql/2010/{06,07,08,09,10,11,12}
ln -fns $T/logs/postgresql "$PGDATA"/logs

/etc/init.d/postgresql start
sleep 2

dropdb unison-20090831
createdb -E UTF-8 unison-20090831

createlang -d unison-20090831 plpgsql
createlang -d unison-20090831 plperl

createuser -D -A -R PUBLIC
createuser -D -A -R genengenes
createuser -D -A -R loader
createuser -D -A -R mathejb
createuser -D -A -R mukhyala
createuser -D -A -R postgres
createuser -D -A -R rkh
createuser -D -A -R unison

