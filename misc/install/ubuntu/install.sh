#!/bin/sh -e
# ubuntu install script for unison


V=8.4

ROOT=$(dirname "$0")
PGTOOLS=/usr/lib/postgresql/$V/bin
PGDATA=/srv/unison


if [ -d "$PGDATA" ]; then
	echo "$PGDATA exists; aborting" 1>&2
	exit 1
fi

mkdir -p "$PGDATA"
chown postgres:postgres "$PGDATA"

sudo -u postgres PS4='+(\u) ' -- bash -ex <<EOF
$PGTOOLS/initdb -D "$PGDATA" -E UTF-8 --no-locale

mkdir /etc/postgresql/8.4/unison
cp -av $ROOT/etc/postgresql/8.4/unison/*.conf /etc/postgresql/8.4/unison/

mkdir -p /var/log/postgresql/unison/201{0,1,2,3}/{01,02,03,04,05,06,07,08,09,10,11,12}

EOF

