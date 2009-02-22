-- This file implements a PostgreSQL table log with
-- partioning.  It uses the same structure as shown
-- http://www.postgresql.org/docs/current/static/runtime-config-logging.html
-- Example: COPY postgres_log FROM '/full/path/to/logfile.csv' WITH csv;

-- Features:
-- * tables are partitioned by date
-- * inserts into the parent table are rewritten as inserts to an
--   appropriate inherited table
-- * partitions on session_start_time to ensure that sessions don't span
--   multiple partitions

-- To do:
-- * indexes

-- Caveats (aka shortcomings I don't expect to address):
-- * updating dates is not supported. 
-- * only one partitioning schedule


-- Triggers are used instead of rules because 1) COPY ignores rules and 2)
-- error checking re: partition constraints is difficult.  Both of these
-- risk the reliability of the logs and the additional (untested)
-- performance cost on loading is a reasonable price for that. See the above
-- URL for details.


DROP TABLE postgres_log CASCADE;
DROP FUNCTION create_log_partition(integer,integer);

CREATE TABLE postgres_log
(
  log_time timestamp(3) with time zone,
  user_name text,
  database_name text,
  process_id integer,
  connection_from text,
  session_id text,
  session_line_num bigint,
  command_tag text,
  session_start_time timestamp with time zone,
  virtual_transaction_id text,
  transaction_id bigint,
  error_severity text,
  sql_state_code text,
  message text,
  detail text,
  hint text,
  internal_query text,
  internal_query_pos integer,
  context text,
  query text,
  query_pos integer,
  location text,
  PRIMARY KEY (session_id, session_line_num)
);

COMMENT ON TABLE postgres_log is 'base table for postgresql logs';



CREATE OR REPLACE FUNCTION postgres_log_insert_trigger()
RETURNS TRIGGER AS $$
DECLARE
    c text;
    ptable text := 'postgres_log';
    ctable text := ptable || '_' || to_char(NEW.session_start_time, 'YYYY_MM');
BEGIN
    -- ITAGAKI Takahiro <itagaki.takahiro@oss.ntt.co.jp>
    -- provided this method:
    c := 'INSERT INTO ' || ctable || ' VALUES( (' || quote_literal(new)
	  || '::' || ptable || ').*)';

    -- In 8.4 (untested):
	-- EXECUTE 'INSERT INTO ' || ctable || ' VALUES( ($1).* )' USING new;

    EXECUTE c;
    RETURN NULL;
END;
$$
LANGUAGE plpgsql;



CREATE TRIGGER insert_postgres_log_trigger
    BEFORE INSERT ON postgres_log
    FOR EACH ROW EXECUTE PROCEDURE postgres_log_insert_trigger();


CREATE OR REPLACE FUNCTION 
create_log_partition(year integer, month integer)
RETURNS text
LANGUAGE plpgsql
AS $_$
DECLARE
	c text;
	ptable text := 'postgres_log';
	ctable text;
	begin_d date;
	end_d date;
	begin_t text;
BEGIN
    begin_d = (year || '-' || month || '-01')::DATE;
	end_d = begin_d + '1 month'::INTERVAL;
	ctable := ptable || '_' || to_char(begin_d, 'YYYY_MM');

	c := 'CREATE TABLE ' || ctable || ' () INHERITS (' || ptable || ')';
	EXECUTE c;

	c := $$ALTER TABLE $$||ctable||$$ ADD CONSTRAINT date_in_correct_partition$$;
	c := c || $$ CHECK (session_start_time >= '$$||begin_d||$$'::DATE AND session_start_time < '$$||end_d||$$'::DATE)$$;
	EXECUTE c;

	RETURN ctable;
END;
$_$;


select create_log_partition(2008,m) from generate_series(1,12) as m;
select create_log_partition(2009,m) from generate_series(1,12) as m;

