$(error THIS MAKEFILE NEEDS TESTING)

include ../common.mk

TARGETS:=${shell cat $(IDFILE)}

default all: $(addsuffix .fa,$(TARGETS))
sigpredict: $(addsuffix .fa.sigpredict,$(TARGETS))
load: $(addsuffix .fa.sigpredict.load,$(TARGETS))

# get sequences
%.fa: %
	cat $< | xargs get-seq >>$@

# run sigpredict
%.fa.sigpredict: %.fa
	sigpredict -c 0 -o $@ $<

# load sigpredict
%.fa.sigpredict.load: %.fa.sigpredict
	~/unison/bin/load-pseqprop $< >$@ 2>&1
