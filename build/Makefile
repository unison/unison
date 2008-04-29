.PHONY: FORCE
.SUFFIXES:
.DELETE_ON_ERROR:

SCHEMA:=go gong marray ncbi pdb pgutils scop tax taxonomy unison unison_aux

default:
	@echo "No $@ target, homey" 1>&2; exit 1

%.sql:
	sudo -u postgres pg_dump -s $(foreach n,${SCHEMA},-n "$n") "$*" >$@.tmp
	/bin/mv -f "$@.tmp" "$@"