-- plregex -- execute a perl regular expression on a string
-- This requires that perl be an 'untrusted' language
-- (i.e., update pg_language set lanpltrusted='f' where lanname='plperl')

-- eg=# select plregex('Reece','/e$/E/g');
--  plregex
-- ---------
--  ReecE
--
-- eg=# select plregex('Reece','/e/E/g');
--  plregex
-- ---------
--  REEcE
--
-- eg=# select plregex('A Long Day\'s Journey Into Night','/n/_/ig');
--              plregex
-- ---------------------------------
--  A Lo_g Day's Jour_ey I_to _ight


create or replace function plregex(text,text) returns text
language plperl as '
my $t = $_[0];
my $sre = "s$_[1]";
eval "\\$t =~ $sre";
return $t;
';

comment on function plregex(text,text) is 'evaluate perl regular expression ( $arg1 =~ s$arg2)';
