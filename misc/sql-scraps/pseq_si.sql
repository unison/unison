SET search_path = unison;

CREATE FUNCTION _pseq_md5len_lookup (text, integer) RETURNS integer
    AS '
DECLARE
	c refcursor;
	rv integer;
BEGIN
	open c for execute ''select pseq_id from pseq where ''
		|| '' md5='' || quote_literal($1) || '' and ''
		|| '' len='' || quote_literal($2) ;
	fetch c into rv;
	close c;
	return rv;
end;'
    LANGUAGE plpgsql;


CREATE FUNCTION _pseq_seq_lookup (text) RETURNS integer
    AS '
BEGIN
	return _pseq_md5len_lookup(md5($1),length($1));
END;'
    LANGUAGE plpgsql;


CREATE or replace FUNCTION pseq_si_pseq_id (text) RETURNS integer
    AS '
DECLARE
        S text;
        rv integer;
        Smd5 text;
BEGIN
        S := clean_sequence($1);
        Smd5 := md5(S);
        rv := _pseq_seq_lookup( S );
        if rv is NULL then
                select into rv pseq_i_pseq_id( S );
        end if;
        return rv;
END;'
    LANGUAGE plpgsql;


