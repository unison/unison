COMPBIO:=/apps/compbio
export BLASTDB:=${COMPBIO}/share/blast
SBPDIR:=${COMPBIO}/share/psiblast_sbp

PROFILES:=$(subst ${SBPDIR}/,,$(wildcard ${SBPDIR}/*/*.chk))
TARGETS:=$(PROFILES:.chk=.pbo-load.log)

PATH:=../../bin:${PATH}
export PGHOST:=


default: $(PROFILES:.chk=.pbo-load.log)
pbo: $(PROFILES:.chk=.pbo)



2003/%.pbo: ${SBPDIR}/2003/%.chk ${SBPDIR}/2003/%.fasta
	@mkdir -p ${@D}
	(time -p blastpgp -b10000 -v10000 -a2 -R $(word 1,$^) -i $(word 2,$^) -daa/unison) >$@.tmp 2>$@.log
	/bin/mv -f $@.tmp $@

2002/%.pbo: ${SBPDIR}/2002/%.chk ${SBPDIR}/2002/%.fasta
	@mkdir -p ${@D}
	(time -p blastpgp -b10000 -v10000 -a2 -R $(word 1,$^) -i $(word 2,$^) -daa/unison) >$@.tmp 2>$@.log
	/bin/mv -f $@.tmp $@

%.pbo-load.log: %.pbo
	load-papssm -Uloader -P$* $< >$@.err 2>&1
	/bin/mv -f $@.err $@
