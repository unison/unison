include ../common.mk

default all: log

# XML release: http://160.80.34.4/mint/release/mint-psi-full-last.zip
# flat : http://160.80.34.4/mint/release/mint-flat-full-last.zip

# fetch mint flat file, save as timestamped file IF CHANGED, symlink as $@
# $@ timestamp is changed IFF contents have changed since last fetch
mint/latest.zip: ${FORCE}
	wget -q -nd -O$@.tmp http://160.80.34.4/mint/release/mint-flat-full-last.zip
	@if [ -f $@ ] && cmp $@ $@.tmp; then \
		echo "# no change in $@"; \
		PS4=''; set -x; /bin/rm -f $@.tmp; \
	else \
		echo "# $@ is new or has been updated"; \
		DESTF=`date +%Y%m%d.zip`; \
		DESTP="${@D}/$${DESTF}"; \
		PS4=''; set -x; \
		/bin/mv -f $@.tmp "$${DESTP}"; \
		/bin/ln -sf "$${DESTF}" $@; \
	fi

dump_full.txt: mint/latest.zip
	unzip $<
	touch -c $@					# tickle dump_full.txt timestamp

mint.log: mint21full.txt
	./load_mint.pl $< >$@ 2>&1


