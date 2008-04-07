CREATE OR REPLACE FUNCTION _seqhash_no_cleaning(text) RETURNS text
    AS $_$DECLARE S text; BEGIN return ( md5($1) || length($1) ); END$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;
CREATE OR REPLACE FUNCTION seqhash(text) RETURNS text
    AS $_$DECLARE S text; BEGIN return ( _seqhash_no_cleaning( clean_sequence($1) ) ); END$_$
    LANGUAGE plpgsql IMMUTABLE STRICT;

ALTER FUNCTION unison._seqhash_no_cleaning(text) OWNER TO unison;
ALTER FUNCTION unison.seqhash(text) OWNER TO unison;

CREATE OR REPLACE UNIQUE INDEX pseq_seqhash_idx ON pseq USING btree (_seqhash_no_cleaning(seq));
