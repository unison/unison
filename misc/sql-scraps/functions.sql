\echo =======================================================================
\echo $Id$

CREATE OR REPLACE FUNCTION digest(text,text) RETURNS bytea AS
 '/home/rkh/unison/lib/libpgcrypto.so','pg_digest' LANGUAGE 'C';

CREATE OR REPLACE FUNCTION md5(text) RETURNS text AS
  'BEGIN return ( encode( digest( \$1, \'md5\' ), \'hex\' ) ); END' LANGUAGE plpgsql;

CREATE FUNCTION clean_sequence(text) RETURNS text AS
	 '/home/rkh/unison/lib/unison.so','pg_clean_sequence' LANGUAGE 'C';

CREATE FUNCTION pl_clean_sequence(text) RETURNS text AS 
	'$_[0] =~ s/[^-A-Za-z*?]//g; $_[0]=uc($_[0]); return $_[0]' LANGUAGE 'plperl';
