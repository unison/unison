## unison/loading/Makefile -- choreographs Unison loading
## $Id: Makefile,v 1.34 2007/06/04 18:00:27 mukhyala Exp $

default all: update

include common.mk
include local.mk
include params.mk

update: phase1 phase2 phase3 phase4 phase5 phase6


CLEANUP_DIRS=


############################################################################
# 1. "AUXILIARY" DATABASES AND SCHEMAS
CLEANUP_DIRS+=aux
.PHONY: phase1
phase1: aux.log
aux.log:
	time -p make -Caux >$@


############################################################################
# 2. LOAD SEQUENCES
CLEANUP_DIRS+=pseq
.PHONY: phase2
phase2: pseq.log

pseq.log: aux.log
# see generic directory rule below


############################################################################
# 3. UPDATE INTRINSIC SETS AND OTHER DATA
# FIXME: mvs/dvs are potentially interdependent and therefore order
# is important.  These should all be moved to the db itself
# for updating.
PHASE3_FX:=update_tax_ids update_psets_intrinsic
PHASE3_MVV:=best_annotation pseq_gene gg_famid_pseq_id ensembl_coordinates ensembl_unambiguous_coordinates ensembl_unambiguous_overlaps
PHASE3_MVDV:=pmprospect_scop
PHASE3_MV:=${PHASE3_MVDV} ${PHASE3_MVV}

.PHONY: phase3
phase3: $(addsuffix .log,${PHASE3_FX}) $(addsuffix _mv.log,${PHASE3_MV})

update_tax_ids.log: pseq.log
update_psets_intrinsic.log: update_tax_ids.log
best_annotation_mv.log: update_tax_ids.log
pmprospect_scop_mv.log: aux.log
pseq_gene_mv.log: aux.log



############################################################################
# 4a. MODELS
# these must be done manually
#MODEL_DIRS:=pmhmm pmprospect pmregexp


############################################################################
# 4b. COMPUTE
# The 'run' target in the COMPUTE_DIRS directories should run current
# sequences as necessary.  This ideal is not fully implemented yet.
#
# IMPORTANT NOTE: Many of the subdir targets submit PBS jobs.  The exit
# status of these targets and the existence of a .log file indicates PBS
# submission only.  The .log files don NOT indicate that the jobs finished
# (or started, even).  Therefore, be careful about using them as
# dependencies elsewhere.

COMPUTE_DIRS:=
COMPUTE_DIRS+=pfbigpi pfnetphos pfpepcoil pfpsipred pfregexp \
	pfseg pfsignalp pftmhmm
# TODO: pfsigcleave?
COMPUTE_DIRS+=pahmm papseq #paprospect
COMPUTE_DIRS+=psprotcomp
# TODO: psdisorder
COMPUTE_DIRS+=pmap
CLEANUP_DIRS+=${COMPUTE_DIRS}
.PHONY: phase4
phase4: $(addsuffix .log,${COMPUTE_DIRS})

$(addsuffix .log,${COMPUTE_DIRS}): %.log: %
	make -C $* update >$@.err 2>&1
	/bin/mv $@.err $@

#paprospect2.log: pmprospect2.log
#pahmm.log: pmhmm.log
#pcluster.log: blat.log



############################################################################
# 5. UPDATE TABLES BASED ON PRECOMPUTED RESULTS
PHASE5_FX:=update_psets_extrinsic
PHASE5_MVV:=pmap pmap_unambiguous pmap_unambiguous_overlaps pmap_locus_representative pmap_gg_representative pseq_probe papseq_pdbcs
PHASE5_MVDV:=
PHASE5_MV:= ${PHASE5_MVDV} ${PHASE5_MVV}

.PHONY: phase5
phase5: update_psets_extrinsic.log $(addsuffix .log,${PHASE5_FX}) $(addsuffix _mv.log,${PHASE5_MV})
pmap_unambiguous_overlaps_mv.log: pmap_unambiguous_mv.log
pmap_locus_representative_mv.log: pmap_unambiguous_overlaps_mv.log

# m_s_u is broken, I think because of temp tables within plpgsql (unverified)
# in any case, the following doesn't work.
#update_meta_stats.log:
#	time -p ${PSQL_VCMD} 'begin; select meta_stats_update(); commit;' >$@.err 2>&1
#	/bin/mv -f $@.err $@


############################################################################
# 6. HOUSEKEEPING
# cluster tables which have cluster indices defined, then vacuum
# and analyze everything. Vacuuming the clustered tables
# is pointless, but it's easier that keeping track of those which
# need it.
.PHONY: phase6
phase6: cleanup.log
cleanup.log:
	(set -x; time -p ${PSQL_VCMD} 'cluster'; time -p ${PSQL_VCMD} 'vacuum analyze') >$@.err 2>&1
	/bin/mv -f $@.err $@




############################################################################
# GENERIC DIRECTORY RULE
# make foo.log makes the default target within the directory foo
# and logs parent make stdout and stderr to foo.log
%.log: %
	make -C $* >$@.err 2>&1
	/bin/mv $@.err $@


############################################################################
# FUNCTIONS AND MATERIALIZED VIEW RULES
# make foo.log makes the default target within the directory foo
# and logs parent make stdout and stderr to foo.log
# NOTE: These rules fail when the _mv doesn't exist yet.  We could
# do either drop/create table as  OR  truncate/insert to update
# views. I chose the latter so that indexes and comments would be
# preserved.

FX=${PHASE3_FX} ${PHASE5_FX}
MVV=${PHASE3_MVV} ${PHASE5_MVV}
MVDV=${PHASE3_MVDV} ${PHASE5_MVDV}

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




clean cleaner cleanest::
	for dir in ${CLEANUP_DIRS}; do make -C $$dir $@; done
clean::
cleaner:: clean
cleanest:: cleaner
	/bin/rm -fr ids
