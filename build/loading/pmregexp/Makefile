## pmregexp/Makefile -- load regular expression sequence motifs into Unison
## $Id$

include ../common.mk
include ../local.mk
include ../params.mk


default:
	@echo no $@ target; exit 1

%.load: %.ids
	(time -p run-pahmm -N250 -p${PAHMM_PARAMS_ID} <$<) >$@.err 2>&1;
	/bin/mv -f $@.err $@.log; touch $@
