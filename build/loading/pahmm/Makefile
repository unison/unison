.SUFFIXES:

P=/apps/compbio
PLATFORM=$(shell ${P}/bin/platform)
EP=${P}/${PLATFORM}
PFAMDB:=$P/share/pfam-9.0/Pfam_fs

Q:=xeons
QSUB:=qsub -q$Q -qall -lwalltime=120000:00,pcput=120000:00,nodes=1:ppn=2 -V

PATH:=${HOME}/csb-db/unison/bin:${EP}/bin:${P}/bin:${PATH}
export PATH

_D:=$(shell mkdir -p load)

default:
	@echo no $@ target; exit 1

ALL:=$(shell cat $r.mt)
all: ${ALL}

# comp-side:
tmp/%.hmmer:
	get-seq -hsvc $* | hmmpfam --informat fasta ${PFAMDB} - >$@.tmp && /bin/mv -f $@.tmp $@
load/%.log: tmp/%.hmmer
	(time -p get-seq -hsvc $* \
	| hmmpfam --informat fasta ${PFAMDB} - \
	| load-pahmm -Uloader -hsvc) >$@.tmp 2>&1 && /bin/mv -f $@.tmp $@
#load/%.log: tmp/%.hmmer
#	load-pahmm -Uloader -hsvc <$@ >$@.tmp 2>&1 && /bin/mv -f $@.tmp $@

$r.d/%.log: $r.d/%
	xargs <$< make -k r=$r >$@


# qsub-side:
$r.mt: $r.ids
	perl -lne 'print "load/$$_.log"' <$< >$@
	@wc -l $@
$r.d: $r.mt
	rm -fr $@; mkdir -p $@
	@nsplit=10; \
	echo "splitting into bins of $$nsplit"; \
	split -l$$nsplit $< $@/
	@echo `find $r.d -type f | wc -l` $r.d targets
$r.d/%.qsub:
	echo 'make r=$r -C${PWD} -k $r.d/$*.log' | ${QSUB} -N$r_$* -o${@D}/$*.out -e${@D}/$*.err 2>&1 | tee $@


qsub: $(addsuffix .qsub, $(wildcard $r.d/??))
qdel:
	qstat -urkh | grep '^[0-9]' | cut -f1 -d. | xargs -t qdel

