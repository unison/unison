\echo =======================================================================
\echo $Id: functions.sql,v 1.2 2002/11/27 00:05:50 rkh Exp $

CREATE OR REPLACE FUNCTION digest(text,text) RETURNS bytea AS
 'libpgcrypto.so','pg_digest' LANGUAGE 'C';

CREATE FUNCTION clean_sequence(text) RETURNS text AS
	 '/home/rkh/unison/lib/unison.so','pg_clean_sequence' LANGUAGE 'C';


CREATE OR REPLACE FUNCTION md5(text) RETURNS text IMMUTABLE AS
  'BEGIN return ( encode( digest( \$1, \'md5\' ), \'hex\' ) ); END' LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION seqhash(text) RETURNS text IMMUTABLE 
 	AS 'DECLARE S text; BEGIN S:=seqrefmt($1); return ( md5(S) || length(S) ); END' LANGUAGE plpgsql;

create or replace function seqrefmt(text) returns text IMMUTABLE AS
	'BEGIN return clean_sequence( upper( $1 ) ); END;' LANGUAGE plpgsql;

CREATE FUNCTION pl_clean_sequence(text) RETURNS text AS 
	'$_[0] =~ s/[^-A-Za-z*?]//g; $_[0]=uc($_[0]); return $_[0]' LANGUAGE 'plperl';

CREATE OR REPLACE FUNCTION RANDSEQ () RETURNS TEXT AS '
	$s=""; $s .= chr(65+rand(26)) for 0..(50+rand(500)); return $s;'
	LANGUAGE 'plperl'; 
