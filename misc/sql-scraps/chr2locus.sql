create or replace function unison.chr2locus(text) returns real
language plpgsql IMMUTABLE as 'BEGIN return chr2locus($1,0)';

create or replace function unison.chr2locus(text,integer) returns real
language plperl IMMUTABLE as '
	$_[0] = ''0'' unless defined $_[0] and $_[0] ne '''';
	$_[1] = ''0'' unless defined $_[0];
	return ($_[0] =~ m/^([XYME])$/ ? 100+ord($1) : $_[0]) . "." . $_[1];
';


select 'NULL', chr2locus(NULL);
select ''	, chr2locus('');
select 22	, chr2locus(22);
select '22'	, chr2locus('22');
select 'X'	, chr2locus('X');
			  
			  
select 'NULL', 123456, chr2locus(NULL,123456);
select ''	, 123456, chr2locus('',123456);
select 22	, 123456, chr2locus(22,123456);
select '22'	, 123456, chr2locus('22',123456);
select 'X'	, 123456, chr2locus('X',123456);
