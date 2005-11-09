## unison/loading/Makefile -- choreographs Unison loading
## $Id: Makefile,v 1.12 2005/10/09 20:13:00 rkh Exp $

## most subdirectories of ./ correspond to table names
## auxiliary schemas are handled in ../aux/


include common.mk
include local.mk
include params.mk


CLEANUP_DIRS=


######################################################################
# 0. "AUXILIARY" DATABASES
# The following rule merely tests whether one table
# from each schema may be selected from.  Errors are
# reported to stderr.  The existence of aux.log 
# signifies that these schemas exist.
.PHONY: phase0
phase0: aux.log
aux.log:
	${PSQL} -c 'select version()' >/dev/null
	${PSQL} -c 'select * from go.association limit 1' >/dev/null
	${PSQL} -c 'select * from gong.alias limit 1' >/dev/null
	${PSQL} -c 'select * from pdb.chain limit 1' >/dev/null
	${PSQL} -c 'select * from scop.cla limit 1' >/dev/null
	${PSQL} -c 'select * from tax.spspec limit 1' >/dev/null
	@echo 'aux schemas exist' >aux.log


######################################################################
# 1. LOAD SEQUENCES
CLEANUP_DIRS+=pseq
.PHONY: phase1
phase1: pseq.log

pseq.log: aux.log
# see generic directory rule below


######################################################################
# 2. UPDATE INTRINSIC SETS AND OTHER DATA
.PHONY: phase2
phase2: update_tax_id.log update_psets_intrinsic.log mv_best_annotation.log pmprospect_scop.log #update_meta_stats.log
update_tax_id.log: pseq.log
	(time -p ${PSQL_VCMD} 'begin; select update_tax_ids(); commit;') >$@.err 2>&1
	/bin/mv -f $@.err $@
update_psets_intrinsic.log: update_tax_id.log
	(time -p ${PSQL_VCMD} 'begin; select update_psets_intrinsic(); commit;') >$@.err 2>&1
	/bin/mv -f $@.err $@
mv_best_annotation.log: update_psets_intrinsic.log
	(time -p ${PSQL_VCMD} 'begin; truncate mv_best_annotation; insert into mv_best_annotation select * from v_best_annotation; commit') >$@.err 2>&1
	/bin/mv -f $@.err $@
pmprospect_scop.log: aux.log
	(PGUSER=unison time -p ${PSQL_VCMD} 'begin; truncate pmprospect_scop; insert into pmprospect_scop select * from dv_pmprospect_scop; commit') >$@.err 2>&1
	/bin/mv -f $@.err $@
# m_s_u is broken, I think because of temp tables within plpgsql (unverified)
# in any case, the following doesn't work.
#update_meta_stats.log:
#	time -p ${PSQL_VCMD} 'begin; select meta_stats_update(); commit;' >$@.err 2>&1
#	/bin/mv -f $@.err $@


######################################################################
# 3. COMPUTE
COMPUTE_DIRS:=
COMPUTE_DIRS+=pahmm paprospect2 papseq #papssm
COMPUTE_DIRS+=pfbigpi pfregexp pfsignalp pfssp_psipred pftmdetect pftmhmm
COMPUTE_DIRS+=psprotcomp
COMPUTE_DIRS+=blat plocus pmhmm
CLEANUP_DIRS+=${COMPUTE_DIRS}
.PHONY: phase3
phase3: $(addsuffix .log,${COMPUTE_DIRS})

paprospect2.log: pmprospect2.log
pahmm.log: pmhmm.log
pcluster.log: blat.log


######################################################################
# 4. UPDATE TABLES BASED ON PRECOMPUTED RESULTS
.PHONY: phase4
phase4: update_psets_extrinsic.log
update_psets_extrinsic.log:
	${PSQL_VCMD} 'begin; truncate meta; select update_psets_intrinsic(); commit;' >$@.err 2>&1
	/bin/mv -f $@.err $@


######################################################################
# 5. HOUSEKEEPING
# cluster tables which have cluster indices defined, then vacuum
# and analyze everything. Vacuuming the clustered tables
# is pointless, but it's easier that keeping track of those which
# need it.
.PHONY: phase5
phase5: cleanup.log
cleanup.log:
	(set -x; time -p ${PSQL_VCMD} 'cluster'; time -p ${PSQL_VCMD} 'vacuum analyze') >$@.err 2>&1
	/bin/mv -f $@.err $@


######################################################################
# GENERIC DIRECTORY RULE
# make foo.log makes the default target within the directory foo
# and logs parent make stdout and stderr to foo.log
%.log: %
	make -C $* >$@.err 2>&1
	/bin/mv $@.err $@



# a silly rule to push .cvsignore patterns into the subdirectories
.PHONY: push-cvsignore
push-cvsignore:
	@for f in */.cvsignore; do (set -x; sort -u -o "$$f" .cvsignore "$$f"); done


clean cleaner cleanest::
	for dir in ${DIRS}; do make -C $$dir $@; done
clean::
cleaner:: clean
cleanest:: cleaner
	/bin/rm -fr ids
