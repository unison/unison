## unison/loading Makefile -- choreographs unison schema loading
## other schemas are handled by directories in csb-db


include defaults.mk
COMPUTE_DIRS:=blat pahmm paprospect2 papseq pappsm  pfregexp pfsignalp pfbigpi pftmdetect plocus pmhmm ppintx pseqprop sst
DIRS=pseq ${COMPUTE_DIRS}

# LOAD SEQUENCES
#seqs.log: 
# handled by generic directory rule


# UPDATE INTRINSIC SETS AND OTHER DATA
.PHONY: phase2
phase2: update_tax_id.log update_psets_intrinsic.log mv_best_annotation.log update_meta_stats.log
update_tax_id.log: seqs.log
	${PSQL_VCMD} 'begin; select update_tax_ids(); commit;' >$@.err 2>&1
	/bin/mv -f $@.err $@
update_psets_intrinsic.log: update_tax_id.log
	${PSQL_VCMD} 'begin; select update_psets_intrinsic(); commit;' >$@.err 2>&1
	/bin/mv -f $@.err $@
mv_best_annotation.log: update_psets_intrinsic.log
	${PSQL_VCMD} 'begin; truncate mv_best_annotation; insert into mv_best_annotation select * from v_best_annotation; commit' >$@.err 2>&1
	/bin/mv -f $@.err $@
update_meta_stats.log:
	${PSQL_VCMD} 'begin; select meta_stats_update(); commit;' >$@.err 2>&1
	/bin/mv -f $@.err $@


# RUN SETS
.PHONY: ids
ids: ids/runA.ids ids/runB.ids ids/runC.ids
ids/runA.ids ids/runB.ids ids/runC.ids: ids/run%.ids: 
	@mkdir -p ${@D}
	make -C ids -f ../defaults.mk ${@F}


# COMPUTE
.PHONY: phase3
phase3: $(addsuffix .log,${COMPUTE_DIRS})

pcluster.log: blat.log


# UPDATE TABLES BASED ON PRECOMPUTED RESULTS
.PHONY: phase4
phase4: update_psets_extrinsic.log
update_psets_extrinsic.log:
	${PSQL_VCMD} 'begin; truncate meta; select update_psets_intrinsic(); commit;' >$@.err 2>&1
	/bin/mv -f $@.err $@



# GENERIC DIRECTORY RULE
%.log: %
	make -C $* >$@.err 2>&1
	/bin/mv $@.err $@


clean cleaner cleanest::
	for dir in ${DIRS}; do make -C $$dir $@; done
clean::
cleaner:: clean
cleanest:: cleaner
	/bin/rm -fr ids
