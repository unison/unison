create or replace function sst_palias_id(integer)
returns integer
language plpgsql as '
DECLARE
	q_id alias for $1;
	a_id integer;
BEGIN
	select into a_id QA.palias_id from pseqalias QA
		join paliasorigin OA on OA.palias_id=QA.palias_id
		where QA.pseq_id=q_id and QA.iscurrent=TRUE and OA.porigin_id=15
		limit 1;
	return a_id;
END;';
