-- sql to create and drop indices from papssm
-- indicies slow thread addition tremendously, but (obviously) speed
-- lookups.  These functions facilitate dropping and creating them.
-- WARNING: creation takes a long time (2 hours?)

create or replace function papssm_create_indices() returns void language plpgsql as '
BEGIN
	create index papssm_eval_idx on papssm(eval);
	raise notice ''created papssm_eval_idx'';
	create index papssm_len_idx on papssm(len);
	raise notice ''created papssm_len_idx'';
	create index papssm_score_idx on papssm(score);
	raise notice ''created papssm_score_idx'';
	create index papssm_ident_idx on papssm(ident);
	raise notice ''created papssm_ident_idx'';
	create index papssm_pos_idx on papssm(pos);
	raise notice ''created papssm_pos_idx'';
	create index papssm_gap_idx on papssm(gap);
	raise notice ''created papssm_gap_idx'';
	return;
END;';


create or replace function papssm_drop_indices() returns void language plpgsql as '
BEGIN
	drop index papssm_eval_idx;
	drop index papssm_len_idx;
	drop index papssm_score_idx;
	drop index papssm_ident_idx;
	drop index papssm_pos_idx;
	drop index papssm_gap_idx;
	return;
END;';
