#!/bin/sh
# pdb-fetch -- PDB file gateway via http non-parsed header
# $Id: nph-pdb-fetch.sh,v 1.4 2006/08/15 18:54:09 rkh Exp $
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
# these point to the root of the rcsb tree
RCSB_BASE_URL=ftp://ftp.rcsb.org/pub/pdb
#RCSB_BASE_URL=ftp://pdb.ccdc.cam.ac.uk/rcsb
#RCSB_BASE_URL=ftp://rutgers.rcsb.org/PDB/pub/pdb
#RCSB_BASE_URL=ftp://pdb.bic.nus.edu.sg/pub/pdb
#RCSB_BASE_URL=ftp://pdb.protein.osaka-u.ac.jp/pub/pdb
#RCSB_BASE_URL=ftp://ftp.pdb.mdc-berlin.de/pub/pdb


### Local PDB directory
# Set this to something bogus (perhaps "/something/bogus"?) 
# to disable local searching
LOCAL_PDB_DIR=/gne/research/data/public/pdb/divided.pdb



export PATH=/usr/bin:/bin

# ID should be just the 4-letter ID
if [ $# -ne 1 ]; then
		echo "$0: need exactly 1 argument, a PDB id (got $#: $*)" 1>&2
		exit 1
fi
ID="$1"
HASH=`expr "$ID" : '.\(..\).'`


# try local file first
FILE="$LOCAL_PDB_DIR/$HASH/$ID.pdb"
if [ -f "$FILE" ]; then
		#echo "found $FILE" 1>&2
		cat "$FILE"
		exit 0
fi

# otherwise, try fetching from a mirror
trap '/bin/rm -f "$TMP";' 0
TMP=`/bin/mktemp`
URL="$RCSB_BASE_URL/data/structures/divided/pdb/$HASH/pdb$ID.ent.Z"
wget -nd -q --retr-symlinks -O- "$URL" | gzip -cdq >"$TMP"
if [ -s "$TMP" ]; then
		#echo "found $URL" 1>&2
		cat "$TMP"
		exit 0
fi

exit 1
