## unison/loading/Makefile -- choreographs Unison loading
## $Id: Makefile,v 1.24 2006/07/20 04:18:48 rkh Exp $

default all: update

include common.mk
include local.mk
include params.mk

update: phase0 phase1 phase2 phase3


CLEANUP_DIRS=


######################################################################
# 0. "AUXILIARY" DATABASES AND SCHEMAS
.PHONY: phase0
phase0: aux.log
aux.log:
	time -p make -Caux >$@


######################################################################
# 1. LOAD SEQUENCES
CLEANUP_DIRS+=pseq
.PHONY: phase1
phase1: pseq.log

pseq.log: aux.log
# see generic directory rule below


######################################################################
# 2. UPDATE INTRINSIC SETS AND OTHER DATA
# FIXME: mvs/dvs are potentially interdependent and therefore order
# is important.  These should all be moved to the db itself
# for updating.
PHASE2_FX:=update_tax_ids update_psets_intrinsic
PHASE2_MVV:=best_annotation pseq_gene gg_famid_pseq_id gg_unq_pro_dna_pseq
PHASE2_MVDV:=pmprospect_scop gg_proid_pseq_id
PHASE2_MV:=${PHASE2_MVDV} ${PHASE2_MVV}

.PHONY: phase2
phase2: $(addsuffix .log,${PHASE2_FX}) $(addsuffix _mv.log,${PHASE2_MV})

update_tax_ids.log: pseq.log
update_psets_intrinsic.log: update_tax_ids.log
best_annotation_mv.log: update_tax_ids.log
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
	make -C $* update >$@.err 2>&1
	/bin/mv $@.err $@

#paprospect2.log: pmprospect2.log
#pahmm.log: pmhmm.log
#pcluster.log: blat.log



######################################################################
# 4. UPDATE TABLES BASED ON PRECOMPUTED RESULTS
PHASE4_FX:=update_psets_extrinsic
PHASE4_MVV:=pmap_unambiguous pmap_unambiguous_overlaps
PHASE4_MVDV:=
PHASE4_MV:= ${PHASE4_MVDV} ${PHASE4_MVV}

.PHONY: phase4
phase4: update_psets_extrinsic.log $(addsuffix .log,${PHASE4_FX}) $(addsuffix _mv.log,${PHASE4_MV})

pmap_unambiguous_overlaps_mv.log: pmap_unambiguous_mv.log


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


######################################################################
# FUNCTIONS AND MATERIALIZED VIEW RULES
# make foo.log makes the default target within the directory foo
# and logs parent make stdout and stderr to foo.log
# NOTE: These rules fail when the _mv doesn't exist yet.  We could
# do either drop/create table as  OR  truncate/insert to update
# views. I chose the latter so that indexes and comments would be
# preserved.

FX=${PHASE2_FX} ${PHASE4_FX}
MVV=${PHASE2_MVV} ${PHASE4_MVV}
MVDV=${PHASE2_MVDV} ${PHASE4_MVDV}

# functions
$(addsuffix .log,${FX}): %.log:
	(time -p ${PSQL_VCMD} 'select $*();') >$@.err 2>&1
	/bin/mv -f $@.err $@
# materialized views from _v views
$(addsuffix _mv.log,${MVV}): %_mv.log:
	(time -p ${PSQL_VCMD} 'truncate $*_mv; insert into $*_mv select * from $*_v; analyze $*_mv;') >$@.err 2>&1
	/bin/mv -f $@.err $@
# materialized views from _dv views
$(addsuffix _mv.log,${MVDV}): %_mv.log:
	(time -p ${PSQL_VCMD} 'truncate $*_mv; insert into $*_mv select * from $*_dv; analyze $*_mv;') >$@.err 2>&1
	/bin/mv -f $@.err $@




# a silly rule to push .cvsignore patterns into the subdirectories
.PHONY: push-cvsignore
push-cvsignore:
	find . -name .cvsignore \
	| sort \
	| while read f; do (set -x; sort -u -o "$$f" .cvsignore "$$f"); done


clean cleaner cleanest::
	for dir in ${DIRS}; do make -C $$dir $@; done
clean::
cleaner:: clean
cleanest:: cleaner
	/bin/rm -fr ids
