## unison/loading/Makefile -- choreographs Unison loading
## $Id: Makefile,v 1.17 2005/12/18 07:49:54 rkh Exp $

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
FX:=update_tax_ids update_psets_intrinsic
MV:=best_annotation pmprospect_scop pseq_gene gg_famid_pseq_id_mv gg_proid_pseq_id_mv gg_unq_pro_dna_pseq_mv
.PHONY: phase2
phase2: $(addsuffix .log,${FX}) $(addsuffix _mv.log,${MV})

# functions
$(addsuffix .log,${FX}): %.log:
	(time -p ${PSQL_VCMD} 'select $*();') >$@.err 2>&1
	/bin/mv -f $@.err $@
update_tax_ids.log: pseq.log
update_psets_intrinsic.log: update_tax_id.log

# materialized views
$(addsuffix _mv.log,${MV}): %_mv.log:
	(time -p ${PSQL_VCMD} 'truncate $*_mv; insert into $* select * from $*_dv;') >$@.err 2>&1
	/bin/mv -f $@.err $@
best_annotation_mv.log: update_psets_intrinsic.log
pmprospect_scop_mv.log: aux.log
pseq_gene_mv.log: aux.log



######################################################################
# 3a. MODELS
# these must be done manually
#MODEL_DIRS:=pmhmm pmprospect pmregexp


######################################################################
# 3b. COMPUTE
# The 'run' target in the COMPUTE_DIRS directories should run current
# sequences as necessary.  This ideal is not fully implemented yet.
#
# IMPORTANT NOTE: Many of the subdir targets submit PBS jobs.  The exit
# status of these targets and the existence of a .log file indicates PBS
# submission only.  The .log files don NOT indicate that the jobs finished
# (or started, even).  Therefore, be careful about using them as
# dependencies elsewhere.

COMPUTE_DIRS:=
COMPUTE_DIRS+=pahmm #paprospect
COMPUTE_DIRS+=pfbigpi pfpsipred pfsignalp pftmhmm
COMPUTE_DIRS+=pmap
#GENELAND only: psprotcomp
#NEEDS ATTENTION: papseq papssm pfregexp
#DEPRECATED: pftmdetect
CLEANUP_DIRS+=${COMPUTE_DIRS}
.PHONY: phase3
phase3: $(addsuffix .log,${COMPUTE_DIRS})

$(addsuffix .log,${COMPUTE_DIRS}): %.log: %
	make -C $* run >$@.err 2>&1
	/bin/mv $@.err $@

#paprospect2.log: pmprospect2.log
#pahmm.log: pmhmm.log
#pcluster.log: blat.log


######################################################################
# 4. UPDATE TABLES BASED ON PRECOMPUTED RESULTS
.PHONY: phase4
phase4: update_psets_extrinsic.log
update_psets_extrinsic.log:
	${PSQL_VCMD} 'truncate meta; select update_psets_intrinsic();' >$@.err 2>&1
	/bin/mv -f $@.err $@

# m_s_u is broken, I think because of temp tables within plpgsql (unverified)
# in any case, the following doesn't work.
#update_meta_stats.log:
#	time -p ${PSQL_VCMD} 'begin; select meta_stats_update(); commit;' >$@.err 2>&1
#	/bin/mv -f $@.err $@


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
