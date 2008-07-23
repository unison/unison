#!/bin/sh
# pdb-fetch -- PDB file gateway via http non-parsed header
# Reece Hart <rkh@gene.com>
#
# Given a PDB id (e.g., 2tnf), this script returns the PDB file on STDOUT
# and exits with status 0, or returns nothing and exits with status 1 if
# the specified PDB isn't found.  The script may look locally (see
# LOCAL_PDB_DIR below) or try to fetch it from a RCSB mirror site (see
# RCSB_BASE_URL).
#
#
# Part of the motiviation is to overcome JMol's refusal to load absolute
# URLs. If placed in a cgi directory and named nph-pdb-fetch.sh (the nph-
# prefix is important), it can be used to load PDBs indirectly.
#


### RCSB mirror
RCSB_BASE_URL='http://www.rcsb.org/pdb/download/downloadFile.do?fileFormat=pdb&compression=NO&structureId='


### Local PDB directory
# Set this to something bogus to disable local searching
# (e.g., "/something/bogus") 
LOCAL_PDB_DIR=/gne/research/data/public/pdb/all.pdb


export PATH=/usr/bin:/bin

# ID should be just the 4-letter ID
if [ $# -ne 1 ]; then
	echo "$0: need exactly 1 argument, a PDB id (got $#: $*)" 1>&2
	exit 1
fi
ID="$1"


# try local file first
FILE="$LOCAL_PDB_DIR/$HASH/$ID.pdb"
if [ -f "$FILE" ]; then
	cat "$FILE"
	exit 0
fi

# otherwise, try fetching from a mirror
trap '/bin/rm -f "$TMP";' 0
TMP=`/bin/mktemp`
URL="${RCSB_BASE_URL}$ID"
exec wget -qO- --retr-symlinks "$URL"
