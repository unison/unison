-- ABORTED.  PROOF AND TEST BEFORE USING.

XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

create or replace function del_palias(integer)
returns void
language plpgsql as '
DECLARE
	v_palias_id alias for $1;
BEGIN
	delete from pseqalias where palias_id=$1;
	delete from paliasorigin where palias_id=$1;
	return;
END;';

