create or replace function canonical_oa_fmt(text,text) returns text language plpgsql
as 'BEGIN return $1 || '':'' || $2; END';

create or replace function canonical_oad_fmt(text,text,text) returns text language plpgsql
as 'BEGIN return $1 || '':'' || $2 || ''('' || $3 || '')''; END';

comment on function canonical_oa_fmt (text,text) is 'format origin,alias into standard format';
comment on function canonical_oad_fmt (text,text,text) is 'format origin,alias,descr into standard format';

grant execute on function canonical_oa_fmt (text,text) to public;
grant execute on function canonical_oad_fmt (text,text,text) to public;
