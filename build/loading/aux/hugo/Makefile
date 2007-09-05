include ../../common.mk
include ../../local.mk
include ../../params.mk


TABLES:=hugo
HUGO_DAT_URL:=http://www.genenames.org/cgi-bin/hgnc_downloads.cgi?title=All+Data;col=gd_hgnc_id;col=gd_app_sym;col=gd_app_name;col=gd_status;col=gd_locus_type;col=gd_prev_sym;col=gd_prev_name;col=gd_aliases;col=gd_pub_chrom_map;col=gd_date2app_or_res;col=gd_date_mod;col=gd_date_name_change;col=gd_pub_acc_ids;col=gd_enz_ids;col=gd_pub_eg_id;col=gd_mgd_id;col=gd_other_ids;col=gd_pubmed_ids;col=gd_pub_refseq_ids;col=gd_gene_fam_name;col=md_gdb_id;col=md_eg_id;col=md_mim_id;col=md_refseq_id;col=md_prot_id;status=Approved;status=Approved+Non-Human;status=Entry+Withdrawn;status_opt=3;=on;where=;order_by=gd_app_sym_sort;limit=;format=text;submit=submit;.cgifields=;.cgifields=chr;.cgifields=status

export PGUSER=unison
_:=$(shell mkdir -p logs)

default all: update

update: $(foreach t,${TABLES},logs/$t-load.log)

hugo.dat: FORCE
	wget -nv -O$@.tmp "${HUGO_DAT_URL}"
	/bin/mv -f $@.tmp $@


$(foreach t,${TABLES},logs/$t-create.log): logs/%.log: sql/%.sql
	-psql -Xf $< 2>&1 | tee $@

$(foreach t,${TABLES},logs/$t-load.log): logs/%-load.log: %.dat FORCE
	tail +2 $< | ${PSQL} -f sql/$*-load.sql | tee $@.err
	/bin/mv -f $@.err $@

cleanest::
	/bin/rm -fr hugo.dat logs
