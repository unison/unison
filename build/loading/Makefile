.SUFFIXES:


all: pseq pseqset

external: scop 

aux: affyannot




%.log: %
	make -C $* 2>&1 | tee $@.err \
	&& /bin/mv $@.err $@


# dependencies
pseqset.log: pseq.log
pcluster.log: blat.log
