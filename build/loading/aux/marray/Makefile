include ../../local.mk
include ../../common.mk
include ../../params.mk

AFFY_ORIGIN_ID:=100002
AGILENT_ORIGIN_ID:=100001

update default all: AFFY.load AGILENT.load

%.load:
	(time -p ./load-probes -o ${$*_ORIGIN_ID}) | ${PSQL} -f - >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@
