CREATE OR REPLACE FUNCTION perftest_platform_id_by_name(text)
RETURNS integer
STRICT IMMUTABLE LANGUAGE SQL
AS $_$ SELECT perftest_platform_id FROM perftest_platform WHERE name=$1 $_$;


CREATE OR REPLACE FUNCTION perftest_platform_si( 
	IN
	ip text,
	mac text,
	uname_s text,
	uname_n text,
	uname_r text,
	uname_m text,
	ram_gb smallint,
	fs_type text,
	pg_version_str text,

	OUT
	perftest_platform_id integer
	) 
STRICT IMMUTABLE
LANGUAGE plpgsql
AS
$_$
DECLARE
	pg_version text := substring(pg_version_str from E'^PostgreSQL (\\S+) ');
BEGIN
	perftest_platform_id := SELECT perftest_platform_id FROM perfest_platform_id P
		ip = P.id
		AND mac = P.mac
		AND uname_s = P.uname_s
		AND uname_n = P.uname_n
		AND uname_r = P.uname_r
		AND uname_m = P.uname_m
		AND ram_gb = P.ram_gb
		AND fs_type = P.fs_type
		AND pg_version_str = P.pg_version_str;

	IF NOT FOUND THEN
		INSERT INTO perftest_platform
			("name, ip", "mac", "uname_s", "uname_n", "uname_r", "uname_m", "ram_gb", "fs_type", "pg_version_str")
			VALUES
			(uname_n || ' (' || pg_version || ')', mac, uname_s, uname_n, uname_r, uname_m, ram_gb, fs_type, pg_version_str)
			;
		perftest_platform_id = lastval;
	END IF;
	
	RETURN perftest_platform_id;
END;
$_$;
