COMPBIO:=/apps/compbio
export BLASTDB:=${COMPBIO}/share/blast
DB:=aa/unison

export BLASTDB:=.
DB:=./needed

SBPDIR:=${COMPBIO}/share/psiblast_sbp



PROFILES:=$(subst ${SBPDIR}/,,$(wildcard ${SBPDIR}/*/*.chk))
TARGETS:=$(PROFILES:.chk=.pbo-load.log)

PATH:=../../bin:${PATH}
export PGHOST:=



default: $(PROFILES:.chk=.pbo-load.log)
pbo: $(PROFILES:.chk=.pbo)



2003/%.pbo: ${SBPDIR}/2003/%.chk ${SBPDIR}/2003/%.fasta
	@mkdir -p ${@D}
	(time -p blastpgp -b10000 -v10000 -a2 -R $(word 1,$^) -i $(word 2,$^) -d${DB}) >$@.tmp 2>$@.log
	/bin/mv -f $@.tmp $@

2002/%.pbo: ${SBPDIR}/2002/%.chk ${SBPDIR}/2002/%.fasta
	@mkdir -p ${@D}
	(time -p blastpgp -b10000 -v10000 -a2 -R $(word 1,$^) -i $(word 2,$^) -d${DB}) >$@.tmp 2>$@.log
	/bin/mv -f $@.tmp $@

%.pbo-load.log: %.pbo
	load-papssm -Uloader -P$* $< >$@.err 2>&1
	/bin/mv -f $@.err $@
