#!/bin/sh
#
# apache_init.d -- init.d startup for apache
#
# chkconfig: 2345 85 15
# description: apache startup script 
# 
# this script sets up the apache environment and ensures that apache
# is started as gwizAdm
#
# $Id: pg_init.d,v 1.1 2004/04/29 21:51:11 rkh Exp $
#

export PATH=/usr/local/apache2/bin:/apps/compbio/i686-linux-2.4/bin:${PATH}

if [ `id -u` = 0 ]; then
	set -x
	exec /usr/bin/sudo -u gWizAdm apachectl "$@"
fi

set -x
exec apachectl "$@"
