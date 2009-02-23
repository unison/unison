create table src_host_ip (
	   src  text NOT NULL,
	   host text,
	   ip   inet,
	   error text,
	   ts	timestamp NOT NULL default now()
)


CREATE OR REPLACE FUNCTION src_bin(IN src text, host text, ip inet, OUT src_bin text)
IMMUTABLE
LANGUAGE PLPGSQL
AS $_$
BEGIN
SELECT INTO src_bin CASE
WHEN src ~ '^65\.55\.' 				THEN 'search.msn.com'
WHEN src ~ '\.search\.msn\.com'		THEN 'search.msn.com'
WHEN src ~ '\.gene\.com'			THEN 'gene.com'
WHEN src ~ '\.googlebot.com'		THEN 'googlebot.com'
WHEN src ~ '\.crawl.yahoo.net'		THEN 'crawl.yahoo.net'
WHEN src ~ '\.exabot.com'			THEN 'exabot.com'
WHEN src ~ '\.searchme.com'			THEN 'searchme.com'
ELSE coalesce(src,host,ip::text)
END;
RETURN;
END;
$_$;




CREATE OR REPLACE VIEW src_bin as
SELECT src,src_bin(src,host,ip) as src_bin
FROM src_host_ip;
