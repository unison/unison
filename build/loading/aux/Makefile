default all: update

include ../common.mk
include ../local.mk
include ../params.mk

DIRS:=ncbi pdb scop tax hugo marray ptm

CLEANUP_DIRS=${DIRS}
ifeq "${GNE}" "1"
DIRS+=sst
endif

LOGS:=$(addsuffix .log,${DIRS})



update: ${LOGS}

${LOGS}: %.log:
	make -C$* update

clean cleaner cleanest::
	for dir in ${CLEANUP_DIRS}; do make -C $$dir $@; done
