#!/bin/sh
#
# pg_init.d -- init.d startup of postgresql
#
# chkconfig: 2345 90 10
# description: postgresql startup
#
# this merely sets a few env variables before calling
# the pg_ctl script provided with postgresql
#
# $Id: pg_init.d,v 1.1 2004/04/29 21:51:11 rkh Exp $
#


SERVICES=/services
PG_CTL=/apps/compbio/i686-linux-2.4/bin/pg_ctl
PG_LOG="$SERVICES"/logs/postgresql.log

export PGDATA="$SERVICES"/postgresql

if [ `id -u` = 0 ]; then
	set -x
	exec /usr/bin/sudo -u compbio "$PG_CTL" -l "$PG_LOG" "$@"
fi

set -x
exec "$PG_CTL" -l "$PG_LOG" "$@"
