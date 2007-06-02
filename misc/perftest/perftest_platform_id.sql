CREATE OR REPLACE FUNCTION perftest_platform_id( 


CREATE OR REPLACE FUNCTION perftest_platform_name( 
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
	perftest_platform_name integer
	) 
STRICT IMMUTABLE
LANGUAGE plpgsql
AS
$_$
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
			(name, ip, mac, uname_s, uname_n, uname_r, uname_m, ram_gb, fs_type, pg_version_str)
			;
		

END;
$_$;
