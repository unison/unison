#export BLASTDB:=.

DB:=./u36.fa
COMPBIO:=/apps/compbio
SBPTOPDIR:=${COMPBIO}/share/psiblast_sbp
SBPDIR:=${SBPTOPDIR}/wf
PROFILES:=$(subst ${SBPTOPDIR}/,,$(wildcard ${SBPDIR}/*.chk))
TARGETS:=$(PROFILES:.chk=.pbo-load.log)

BLASTPGP:=/apps/compbio/i686-linux-2.4/opt/blast-2.2.6/blastpgp
LOAD-PAPSSM:=/home/rkh/csb-db/unison/sbin/load-papssm

BLASTDB=${COMPBIO}/share/blast
export BLASTDB

export PGHOST=td-svc
export PGPASSWORD=marge


default: $(PROFILES:.chk=.pbo-load.log)
pbo: $(PROFILES:.chk=.pbo)



2003/%.pbo: ${SBPTOPDIR}/2003/%.chk ${SBPTOPDIR}/2003/%.fasta
	@mkdir -p ${@D}
	(time -p blastpgp -b10000 -v10000 -a2 -R $(word 1,$^) -i $(word 2,$^) -d${DB}) >$@.tmp 2>$@.log
	/bin/mv -f $@.tmp $@

2002/%.pbo: ${SBPTOPDIR}/2002/%.chk ${SBPTOPDIR}/2002/%.fasta
	@mkdir -p ${@D}
	(time -p blastpgp -b10000 -v10000 -a2 -R $(word 1,$^) -i $(word 2,$^) -d${DB}) >$@.tmp 2>$@.log
	/bin/mv -f $@.tmp $@

wf/%.pbo: ${SBPTOPDIR}/wf/%.chk ${SBPTOPDIR}/wf/%.fasta
	@mkdir -p ${@D}
	(time -p ${BLASTPGP} -b10000 -v10000 -a2 -R $(word 1,$^) -i $(word 2,$^) -d${DB}) >$@.tmp 2>$@.log
	/bin/mv -f $@.tmp $@

%.pbo-load.log: %.pbo
	${LOAD-PAPSSM} -dcsb-dev -Uloader -p8 -P$* $< >$@.err 2>&1
	/bin/mv -f $@.err $@
