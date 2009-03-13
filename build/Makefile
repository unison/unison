.PHONY: FORCE
.SUFFIXES:
.DELETE_ON_ERROR:

# FIXME: When config is centralized, these should move there.
SCHEMA:=go gong marray ncbi pdb pgutils scop sst tax taxonomy unison unison_aux
export PGHOST:=respgsql
export PGPASSFILE:=${HOME}/.pgpass-cron

default:
	@echo "No $@ target, homey" 1>&2; exit 1

%.sql: FORCE
	pg_dump -h respgsql -U postgres -s $(foreach n,${SCHEMA},-n "$n") "$*" >$@.tmp
	/bin/mv -f "$@.tmp" "$@"
