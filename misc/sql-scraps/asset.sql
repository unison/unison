create or replace function set_append(text,text) returns text language plpgsql as '
BEGIN
	if $1 is null or $1 = '''' then
		return $2;
	else
		return $1 || '','' || $2;
	end if;
END;';

create aggregate asset (basetype=text, stype=text, sfunc=set_append );
