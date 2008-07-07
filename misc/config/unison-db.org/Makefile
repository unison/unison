.SUFFIXES:
.PHONY: FORCE

FILES=etc/apache2/vhosts.d/unison.conf home/rkh/etc/init.d/postgresql home/rkh/postgresql/8.3/postgresql.conf home/rkh/postgresql/8.3/pg_hba.conf


default:
	@echo "No $@ target, homey." 1>&2; exit 1

install: $(addsuffix -install,${FILES})
%-install: FORCE
	mkdir -p /${*D}
	/bin/cp --parents -auv $* /

archive: $(addsuffix -archive,${FILES})
%-archive:
	mkdir -p ${*D}
	/bin/cp --parents -auv /$* .
