# pfam-prep.mk -- a makefile to prepare a Pfam distribution for
# local use
# 
# USE (I think):
# $ cd pfam/
# $ make -f ../adm/bin/pfam-prep.mk


.SUFFIXES:
.PHONY: FORCE
.DELETE_ON_ERROR:


default all: Pfam_fs.hmmb Pfam_fs.hmmb.ssi Pfam_ls.hmmb Pfam_ls.hmmb.ssi


#NOT PRECIOUS: %.hmm
# build if you want, but I'd rather that people
# use the binary versions in .hmmb below
%.hmm: %.gz
	gzip -cdq <$< >$@

.PRECIOUS: %.hmmb
%.hmmb: %.hmm
	hmmconvert -b $< $@

.PRECIOUS: %.ssi
%.ssi: %
	hmmindex $<
