-- sql to create and drop indices from p2thread
-- indicies slow thread addition tremendously, but (obviously) speed
-- lookups.  These functions facilitate dropping and creating them.
-- WARNING: creation takes a long time (2 hours?)

create or replace function p2thread_create_indices() returns void language plpgsql as '
BEGIN
	create index p2thread_gap_idx on p2thread (gap);
	raise notice ''created p2thread_gap_idx'';
	create index p2thread_mutation_idx on p2thread (mutation);
	raise notice ''created p2thread_mutation_idx'';
	create index p2thread_nalign_idx on p2thread (nalign);
	raise notice ''created p2thread_nalign_idx'';
	create index p2thread_nident_idx on p2thread (nident);
	raise notice ''created p2thread_nident_idx'';
	create index p2thread_pairwise_idx on p2thread (pairwise);
	raise notice ''created p2thread_pairwise_idx'';
	create index p2thread_quality_idx on p2thread (quality);
	raise notice ''created p2thread_quality_idx'';
	create index p2thread_raw_idx on p2thread (raw);
	raise notice ''created p2thread_raw_idx'';
	create index p2thread_rgyr_idx on p2thread (rgyr);
	raise notice ''created p2thread_rgyr_idx'';
	create index p2thread_singleton_idx on p2thread (singleton);
	raise notice ''created p2thread_singleton_idx'';
	create index p2thread_ssfit_idx on p2thread (ssfit);
	raise notice ''created p2thread_ssfit_idx'';
	create index p2thread_start_idx on p2thread (start);
	raise notice ''created p2thread_start_idx'';
	create index p2thread_stop_idx on p2thread (stop);
	raise notice ''created p2thread_stop_idx'';
	create index p2thread_svm_idx on p2thread (svm);
	raise notice ''created p2thread_svm_idx'';
	create index p2thread_zscore_idx on p2thread (zscore);
	raise notice ''created p2thread_zscore_idx'';
	return;
END;';


create or replace function p2thread_drop_indices() returns void language plpgsql as '
BEGIN
	drop index p2thread_gap_idx;
	drop index p2thread_mutation_idx;
	drop index p2thread_nalign_idx;
	drop index p2thread_nident_idx;
	drop index p2thread_pairwise_idx;
	drop index p2thread_quality_idx;
	drop index p2thread_raw_idx;
	drop index p2thread_rgyr_idx;
	drop index p2thread_singleton_idx;
	drop index p2thread_ssfit_idx;
	drop index p2thread_start_idx;
	drop index p2thread_stop_idx;
	drop index p2thread_svm_idx;
	drop index p2thread_zscore_idx;
	return;
END;';
