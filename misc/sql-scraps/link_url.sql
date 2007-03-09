CREATE OR REPLACE FUNCTION link_url(integer, text) RETURNS text
    AS $_$
DECLARE
	row record;
	_o alias for $1;
	_a text = $2;
BEGIN
	SELECT INTO row origin,link_url FROM origin WHERE origin_id=_o;
	IF NOT FOUND THEN
		RAISE EXCEPTION 'origin_id=% does not exist', _o;
	END IF;
	IF row.link_url IS NULL THEN
		RAISE WARNING 'link_url for origin_id=% is null', _o;
	END IF;

	IF row.origin ~ '^Pfam' THEN
		-- Pfam links against only the unversioned accession
		_a = split_part(_a,'.',1);
	END IF;

	-- %a -- alias
	-- %s -- alias, deprecated
	return replace(replace(row.link_url,'%a',_a),'%s',_a);
END;
$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;
