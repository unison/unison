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
This script tests kerberos authentication by using your saved krb
credentials (server-side) to log in to a remote machine.  Here we go...
=======================================================================
EOF


if [ -z "$AUTH_TYPE" ]; then
	echo "AUTH_TYPE isn't defined... this is pointless"
	exit 1
fi

date
echo "AUTH_TYPE=$AUTH_TYPE"
echo "REMOTE_USER=$REMOTE_USER"

SC="/tmp/krb5cc_$REMOTE_USER"
if [ \! -f "$SC" ]; then
	echo "$SC doesn't exist!"
	echo "My guess is that credentials are being saved"
	exit 2
fi

export KRB5CCNAME="FILE:$SC"
echo "KRB5CCNAME=$KRB5CCNAME";
ls -l $SC

cmd="/usr/kerberos/bin/rsh geneland -x -l $REMOTE_USER sh -c '(set -x; hostname; id; date; pwd; ls) 2>&1'"
echo
echo "now, what you've all been waiting for..."
echo "remote execution of << $cmd >>"

# can't pipe into nl 
$cmd >$TMPFILE
STATUS=$?
nl <$TMPFILE

exit $STATUS

