create or replace function public._asset(text,text)
returns text
language plpgsql as '
BEGIN
	if $1 is null or $1 = '''' then
		return $2;
	else
		return $1 || '','' || $2;
	end if;
END;';
comment on function public._asset(text,text) is 'see asset aggregate function';

create aggregate public.asset (basetype=text, stype=text, sfunc=_asset);
comment on aggregate asset(text) is 'aggregate to accumulate a comma-separated list of options';
