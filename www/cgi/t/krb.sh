#!/bin/sh 
# tests krb saved credentials by (remote) logging into geneland using the
# credentials to run a few innocuous commands
# $Id$


exec 2>&1

TMPFILE=/tmp/krb.sh-$$


# Note: the script ALWAYS returns 0 for the sake of CGI calling, even
# though I use $?  to indicate errors
on_exit () {
	if [ "$?" = 0 ]; then
		echo "kerberos test exited normally ($?)"
	else
		echo "!!! ABNORMAL EXIT ($?)";
	fi
	/bin/rm -f "$TMPFILE"
	exit 0;
	}
trap on_exit EXIT
set -e


echo "Content-type: text/plain"
echo


cat <<EOF
# \$Id$

This script tests kerberos authentication by using your saved krb
credentials (server-side) to log in to a remote machine.  Here we go...
=======================================================================
EOF

date

echo "REMOTE_USER=$REMOTE_USER"
USER=`expr "$REMOTE_USER" : '\(.*\)@GENE.COM'`


if [ -z "$AUTH_TYPE" ]; then
	echo "AUTH_TYPE isn't defined... this is pointless"
	exit 1
fi
echo "AUTH_TYPE=$AUTH_TYPE"

if [ -z "$KRB5CCNAME" ]; then
	echo "KRB5CCNAME isn't defined... bailing"
	exit 1
fi
echo "KRB5CCNAME=$KRB5CCNAME";

SC=`expr "$KRB5CCNAME" : 'FILE:\(.*\)'`
if [ -z "$SC" ]; then
	echo "Couldn't parse $KRB5CCNAME for a filename... bailing"
	exit 1
fi

if [ \! -f "$SC" ]; then
	echo "$SC doesn't exist!"
	echo "My guess is that credentials are not being saved"
	exit 2
fi

/bin/ls -l $SC


cmd="/usr/lib/heimdal/bin/rsh gwiz -l $USER sh -c '(set -x; hostname; id; date; pwd; ls) 2>&1'"
echo
echo "now, what you've all been waiting for..."
echo "remote execution of << $cmd >>"

# can't pipe into nl 
$cmd >$TMPFILE
STATUS=$?
nl <$TMPFILE

exit $STATUS

