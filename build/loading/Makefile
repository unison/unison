## unison/loading Makefile -- choreographs all loading

include defaults.mk


# LOAD SEQUENCES


# UPDATE INTRINSIC SETS AND OTHER DATA
update_tax_id.log:
	${PSQL_CMD} 'begin; select update_tax_ids(); commit;' >$@.err 2>&1
	/bin/mv -f $@.err $@

update_psets_intrinsic.log:
	${PSQL_CMD} 'begin; select update_psets_intrinsic(); commit;' >$@.err 2>&1
	/bin/mv -f $@.err $@

mv_best_annotation.log:
	${PSQL_CMD} 'begin; truncate mv_best_annotation; insert into mv_best_annotation select * from v_best_annotation; commit' >$@.err 2>&1
	/bin/mv -f $@.err $@


# COMPUTE
DIRS:=affyannot blat pahmm paprospect2 papseq pappsm pfbigpi pftmdetect plocus pmhmm ppintx pseq pseqprop sst
%.log: %
	make -C $* >$@.err 2>&1
	/bin/mv $@.err $@


# UPDATE TABLES BASED ON PRECOMPUTED RESULTS
update_psets_extrinsic.log:
	${PSQL_CMD} 'begin; select update_psets_intrinsic(); commit;' >$@.err 2>&1
	/bin/mv -f $@.err $@



# DEPENDENCIES
pcluster.log: blat.log



clean cleaner cleanest::
	@for dir in ${DIRS}; do make -C $$dir $@; done
