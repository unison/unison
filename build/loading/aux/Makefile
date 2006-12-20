default all: update

include ../common.mk
include ../local.mk
include ../params.mk

DIRS:=ncbi pdb scop tax hugo marray
ifeq "${GNE}" "1"
DIRS+=sst
endif

LOGS:=$(addsuffix .log,${DIRS})



update: ${LOGS}

${LOGS}: %.log:
	make -C$* update
