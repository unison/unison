CREATE OR REPLACE function get_run_timestamp(integer, integer) RETURNS timestamp with time zone AS '
DECLARE
    q alias for $1;
    r alias for $2;
    z timestamp;
BEGIN
    select into z ran_on from run_history
        where pseq_id=q
        and run_id=r;
    return z;
END;
' LANGUAGE 'plpgsql';

comment on function get_run_timestamp(integer,integer) is 'for the given pseq_id and run_id, returns the ran_on timestamp from run_history';

